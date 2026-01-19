//
//  StorageManager.swift
//  QuickNovel
//
//  Manages local storage for bookmarks, history, and settings
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    // MARK: - Bookmarks
    func saveBookmark(_ bookmark: Bookmark) {
        var bookmarks = getBookmarks()
        bookmarks.append(bookmark)
        save(bookmarks, forKey: "bookmarks")
    }
    
    func getBookmarks() -> [Bookmark] {
        return load([Bookmark].self, forKey: "bookmarks") ?? []
    }
    
    func removeBookmark(novelUrl: String) {
        var bookmarks = getBookmarks()
        bookmarks.removeAll { $0.url == novelUrl }
        save(bookmarks, forKey: "bookmarks")
    }
    
    func isBookmarked(novelUrl: String) -> Bool {
        return getBookmarks().contains { $0.url == novelUrl }
    }
    
    // MARK: - History
    func saveHistoryEntry(_ entry: HistoryEntry) {
        var history = getHistory()
        
        // Remove existing entry for this novel
        history.removeAll { $0.url == entry.url }
        
        // Add new entry at the beginning
        history.insert(entry, at: 0)
        
        // Keep only last 100 entries
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        
        save(history, forKey: "readingHistory")
    }
    
    func getHistory() -> [HistoryEntry] {
        return load([HistoryEntry].self, forKey: "readingHistory") ?? []
    }
    
    func clearHistory() {
        defaults.removeObject(forKey: "readingHistory")
    }
    
    // MARK: - Reading Progress
    func saveReadingProgress(_ progress: ReadingProgress) {
        var allProgress = getReadingProgress()
        
        // Update or add progress
        if let index = allProgress.firstIndex(where: { $0.novelUrl == progress.novelUrl }) {
            allProgress[index] = progress
        } else {
            allProgress.append(progress)
        }
        
        save(allProgress, forKey: "readingProgress")
    }
    
    func getReadingProgress(for novelUrl: String) -> ReadingProgress? {
        return getReadingProgress().first { $0.novelUrl == novelUrl }
    }
    
    func getReadingProgress() -> [ReadingProgress] {
        return load([ReadingProgress].self, forKey: "readingProgress") ?? []
    }
    
    // MARK: - Downloads
    func saveDownload(_ download: DownloadData) {
        var downloads = getDownloads()
        downloads.append(download)
        save(downloads, forKey: "completedDownloads")
    }
    
    func getDownloads() -> [DownloadData] {
        return load([DownloadData].self, forKey: "completedDownloads") ?? []
    }
    
    func removeDownload(novelUrl: String) {
        var downloads = getDownloads()
        downloads.removeAll { $0.url == novelUrl }
        save(downloads, forKey: "completedDownloads")
    }
    
    // MARK: - Settings
    func saveReadingSettings(_ settings: ReadingSettings) {
        save(settings, forKey: "readingSettings")
    }
    
    func getReadingSettings() -> ReadingSettings {
        return load(ReadingSettings.self, forKey: "readingSettings") ?? ReadingSettings()
    }
    
    func saveAppSettings(_ settings: AppSettings) {
        save(settings, forKey: "appSettings")
    }
    
    func getAppSettings() -> AppSettings {
        return load(AppSettings.self, forKey: "appSettings") ?? AppSettings()
    }
    
    // MARK: - Generic Save/Load
    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? encoder.encode(value) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
