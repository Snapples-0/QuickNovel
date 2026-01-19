//
//  ViewModels.swift
//  QuickNovel
//
//  All ViewModels for the app
//

import Foundation
import SwiftUI

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var featuredNovels: [SearchResponse] = []
    @Published var popularNovels: [SearchResponse] = []
    @Published var latestNovels: [SearchResponse] = []
    @Published var isLoading = false
    @Published var selectedProvider: String? = nil
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load from first available provider
            if let provider = ProviderRegistry.shared.getAllProviders().first {
                let response = try await provider.loadMainPage(page: 1, category: nil, orderBy: nil, tag: nil)
                featuredNovels = Array(response.results.prefix(5))
                popularNovels = Array(response.results.prefix(10))
                latestNovels = response.results
            }
        } catch {
            print("Error loading home data: \(error)")
        }
    }
    
    func refresh() async {
        await loadData()
    }
}

// MARK: - Search ViewModel
@MainActor
class SearchViewModel: ObservableObject {
    @Published var results: [SearchResponse] = []
    @Published var isLoading = false
    @Published var selectedProvider: ProviderInfo?
    
    func search(query: String) async {
        guard !query.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let providerName = selectedProvider?.name,
               let provider = ProviderRegistry.shared.getProvider(byName: providerName) {
                // Search specific provider
                results = try await provider.search(query: query)
            } else {
                // Search all providers
                var allResults: [SearchResponse] = []
                for provider in ProviderRegistry.shared.getAllProviders() {
                    if let searchResults = try? await provider.search(query: query) {
                        allResults.append(contentsOf: searchResults)
                    }
                }
                results = allResults
            }
        } catch {
            print("Search error: \(error)")
        }
    }
    
    func clearResults() {
        results = []
    }
}

// MARK: - Novel Detail ViewModel
@MainActor
class NovelDetailViewModel: ObservableObject {
    @Published var novel: StreamResponse?
    @Published var chapters: [ChapterData] = []
    @Published var isLoading = false
    
    let novelUrl: String
    let providerName: String?
    
    init(novelUrl: String, providerName: String?) {
        self.novelUrl = novelUrl
        self.providerName = providerName
    }
    
    func loadNovelDetails() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let provider = findProvider()
            let response = try await provider.load(url: novelUrl)
            
            if let streamResponse = response as? StreamResponse {
                novel = streamResponse
                chapters = streamResponse.data
            }
        } catch {
            print("Error loading novel: \(error)")
        }
    }
    
    func sortChapters(ascending: Bool) {
        if ascending {
            chapters.sort { $0.name < $1.name }
        } else {
            chapters.sort { $0.name > $1.name }
        }
    }
    
    private func findProvider() -> NovelProvider {
        if let providerName = providerName,
           let provider = ProviderRegistry.shared.getProvider(byName: providerName) {
            return provider
        }
        
        // Try to find provider from URL
        for provider in ProviderRegistry.shared.getAllProviders() {
            if novelUrl.contains(provider.baseUrl) {
                return provider
            }
        }
        
        // Default to first provider
        return ProviderRegistry.shared.getAllProviders().first!
    }
}

// MARK: - Reader ViewModel
@MainActor
class ReaderViewModel: ObservableObject {
    @Published var chapterContent: ChapterContent?
    @Published var currentChapter: ChapterData?
    @Published var isLoading = false
    @Published var settings = ReadingSettings()
    @Published var displayText: String = ""
    
    let chapters: [ChapterData]
    
    init(chapters: [ChapterData]) {
        self.chapters = chapters
        loadSettings()
    }
    
    func loadChapter(at index: Int) async {
        guard index >= 0 && index < chapters.count else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        currentChapter = chapters[index]
        
        do {
            // Find provider for chapter URL
            let provider = findProvider(for: chapters[index].url)
            chapterContent = try await provider.loadHtml(url: chapters[index].url)
            
            // Cache display text
            displayText = chapterContent?.plainText ?? HTMLParser.htmlToPlainText(chapterContent?.html ?? "")
            
            // Save reading progress
            saveProgress(chapterIndex: index)
        } catch {
            print("Error loading chapter: \(error)")
        }
    }
    
    private func findProvider(for url: String) -> NovelProvider {
        for provider in ProviderRegistry.shared.getAllProviders() {
            if url.contains(provider.baseUrl) {
                return provider
            }
        }
        return ProviderRegistry.shared.getAllProviders().first!
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "readingSettings"),
           let decoded = try? JSONDecoder().decode(ReadingSettings.self, from: data) {
            settings = decoded
        }
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "readingSettings")
        }
    }
    
    private func saveProgress(chapterIndex: Int) {
        // Save to history
        let progress = ReadingProgress(
            novelUrl: currentChapter?.url ?? "",
            chapterUrl: currentChapter?.url ?? "",
            characterPosition: 0,
            scrollPosition: 0,
            lastUpdated: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: "lastReadingProgress")
        }
    }
}

// MARK: - Downloads ViewModel
@MainActor
class DownloadsViewModel: ObservableObject {
    @Published var activeDownloads: [DownloadProgress] = []
    @Published var completedDownloads: [DownloadData] = []
    
    func loadDownloads() async {
        // Load from persistent storage
        if let data = UserDefaults.standard.data(forKey: "completedDownloads"),
           let decoded = try? JSONDecoder().decode([DownloadData].self, from: data) {
            completedDownloads = decoded
        }
    }
}

// MARK: - History ViewModel
@MainActor
class HistoryViewModel: ObservableObject {
    @Published var history: [HistoryEntry] = []
    
    func loadHistory() async {
        if let data = UserDefaults.standard.data(forKey: "readingHistory"),
           let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            history = decoded.sorted { $0.lastAccessDate > $1.lastAccessDate }
        }
    }
    
    func deleteHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func clearAllHistory() {
        history = []
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "readingHistory")
        }
    }
}
