//
//  DownloadManager.swift
//  QuickNovel
//
//  Handles novel and EPUB downloads
//

import Foundation

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var activeDownloads: [String: DownloadProgress] = [:]
    
    private let fileManager = FileManager.default
    private let downloadQueue = DispatchQueue(label: "com.quicknovel.downloads", attributes: .concurrent)
    
    private init() {
        createDownloadDirectory()
    }
    
    private func createDownloadDirectory() {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let downloadPath = documentsPath.appendingPathComponent("Downloads")
        
        if !fileManager.fileExists(atPath: downloadPath.path) {
            try? fileManager.createDirectory(at: downloadPath, withIntermediateDirectories: true)
        }
    }
    
    func startDownload(novel: StreamResponse, chapters: [ChapterData]) async throws {
        let progress = DownloadProgress(
            novelUrl: novel.url,
            state: .downloading(progress: 0),
            currentChapter: 0,
            totalChapters: chapters.count,
            bytesDownloaded: 0,
            totalBytes: 0
        )
        
        await MainActor.run {
            activeDownloads[novel.url] = progress
        }
        
        // Download chapters
        for (index, chapter) in chapters.enumerated() {
            do {
                let provider = findProvider(for: chapter.url)
                let content = try await provider.loadHtml(url: chapter.url)
                
                // Save chapter locally
                try await saveChapter(novelUrl: novel.url, chapter: chapter, content: content)
                
                // Update progress
                let newProgress = Double(index + 1) / Double(chapters.count)
                await MainActor.run {
                    activeDownloads[novel.url]?.state = .downloading(progress: newProgress)
                    activeDownloads[novel.url]?.currentChapter = index + 1
                }
            } catch {
                await MainActor.run {
                    activeDownloads[novel.url]?.state = .failed(error: error.localizedDescription)
                }
                throw error
            }
        }
        
        // Generate EPUB
        try await generateEPUB(novel: novel, chapters: chapters)
        
        // Mark as completed
        await MainActor.run {
            activeDownloads[novel.url]?.state = .completed
        }
    }
    
    func pauseDownload(novelUrl: String) {
        // Implementation for pausing downloads
    }
    
    func resumeDownload(novelUrl: String) {
        // Implementation for resuming downloads
    }
    
    func cancelDownload(novelUrl: String) {
        activeDownloads.removeValue(forKey: novelUrl)
    }
    
    private func saveChapter(novelUrl: String, chapter: ChapterData, content: ChapterContent) async throws {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ProviderError.networkError("Cannot access documents directory")
        }
        
        let novelPath = documentsPath
            .appendingPathComponent("Downloads")
            .appendingPathComponent(novelUrl.sanitizedFilename())
        
        if !fileManager.fileExists(atPath: novelPath.path) {
            try fileManager.createDirectory(at: novelPath, withIntermediateDirectories: true)
        }
        
        let chapterPath = novelPath.appendingPathComponent("\(chapter.slug).html")
        try content.html.write(to: chapterPath, atomically: true, encoding: .utf8)
    }
    
    private func generateEPUB(novel: StreamResponse, chapters: [ChapterData]) async throws {
        // Basic EPUB generation
        // In production, would use a proper EPUB library
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let epubPath = documentsPath
            .appendingPathComponent("Downloads")
            .appendingPathComponent("\(novel.name.sanitizedFilename()).epub")
        
        // Create EPUB structure
        // This is a placeholder - would implement full EPUB generation
    }
    
    private func findProvider(for url: String) -> NovelProvider {
        for provider in ProviderRegistry.shared.getAllProviders() {
            if url.contains(provider.baseUrl) {
                return provider
            }
        }
        // Default to RoyalRoad as fallback
        return ProviderRegistry.shared.getAllProviders().first ?? RoyalRoadProvider()
    }
}
