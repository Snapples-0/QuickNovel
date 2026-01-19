//
//  Models.swift
//  QuickNovel
//
//  Core data models for novels, chapters, and responses
//

import Foundation

// MARK: - Search Response
struct SearchResponse: Codable, Identifiable {
    let id = UUID()
    let name: String
    let url: String
    let posterUrl: String?
    let rating: Int?
    let latestChapter: String?
    let author: String?
    let synopsis: String?
    
    enum CodingKeys: String, CodingKey {
        case name, url, posterUrl, rating, latestChapter, author, synopsis
    }
}

// MARK: - Novel Detail Response
protocol LoadResponse {
    var name: String { get }
    var url: String { get }
    var posterUrl: String? { get }
    var rating: Int? { get }
    var synopsis: String? { get }
    var tags: [String]? { get }
    var author: String? { get }
}

struct StreamResponse: LoadResponse, Codable {
    let name: String
    let url: String
    let posterUrl: String?
    let rating: Int?
    let synopsis: String?
    let tags: [String]?
    let author: String?
    let data: [ChapterData]
    let apiName: String
}

struct EpubResponse: LoadResponse, Codable {
    let name: String
    let url: String
    let posterUrl: String?
    let rating: Int?
    let synopsis: String?
    let tags: [String]?
    let author: String?
    let epubUrl: String
    let apiName: String
}

// MARK: - Chapter Data
struct ChapterData: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let slug: String
    let url: String
    let dateOfRelease: String?
    
    enum CodingKeys: String, CodingKey {
        case name, slug, url, dateOfRelease
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChapterData, rhs: ChapterData) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Main Page Response
struct MainPageResponse: Codable {
    let apiName: String
    let results: [SearchResponse]
}

// MARK: - User Review
struct UserReview: Codable, Identifiable {
    let id = UUID()
    let username: String
    let rating: Int
    let comment: String
    let date: String?
    
    enum CodingKeys: String, CodingKey {
        case username, rating, comment, date
    }
}

// MARK: - Chapter Content
struct ChapterContent: Codable {
    let url: String
    let html: String
    let plainText: String?
}

// MARK: - Download Data
struct DownloadData: Codable, Identifiable {
    let id = UUID()
    let novelName: String
    let url: String
    let posterUrl: String?
    let author: String?
    let filePath: String
    let downloadedDate: Date
    let fileSize: Int64
    let epubUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case novelName, url, posterUrl, author, filePath, downloadedDate, fileSize, epubUrl
    }
}

// MARK: - Reading History
struct HistoryEntry: Codable, Identifiable {
    let id = UUID()
    let novelName: String
    let url: String
    let posterUrl: String?
    let lastChapterName: String
    let lastChapterUrl: String
    let lastAccessDate: Date
    let readingPosition: Int
    let totalChapters: Int?
    
    enum CodingKeys: String, CodingKey {
        case novelName, url, posterUrl, lastChapterName, lastChapterUrl, lastAccessDate, readingPosition, totalChapters
    }
}

// MARK: - Bookmark
struct Bookmark: Codable, Identifiable {
    let id = UUID()
    let novelName: String
    let url: String
    let posterUrl: String?
    let author: String?
    let addedDate: Date
    let totalChapters: Int?
    let lastReadChapter: String?
    
    enum CodingKeys: String, CodingKey {
        case novelName, url, posterUrl, author, addedDate, totalChapters, lastReadChapter
    }
}

// MARK: - Reading Progress
struct ReadingProgress: Codable {
    let novelUrl: String
    let chapterUrl: String
    let characterPosition: Int
    let scrollPosition: Double
    let lastUpdated: Date
}

// MARK: - Download Progress
enum DownloadState {
    case idle
    case downloading(progress: Double)
    case paused(progress: Double)
    case completed
    case failed(error: String)
}

struct DownloadProgress {
    let novelUrl: String
    var state: DownloadState
    var currentChapter: Int
    var totalChapters: Int
    var bytesDownloaded: Int64
    var totalBytes: Int64
}

// MARK: - Resource State
enum ResourceState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
}

// MARK: - Provider Info
struct ProviderInfo: Identifiable {
    let id = UUID()
    let name: String
    let displayName: String
    let baseUrl: String
    let supportedFeatures: [ProviderFeature]
}

enum ProviderFeature {
    case search
    case browse
    case reviews
    case download
    case epub
}

// MARK: - Reading Settings
struct ReadingSettings: Codable {
    var fontSize: CGFloat = 18
    var fontName: String = "System"
    var textColor: String = "#000000"
    var backgroundColor: String = "#FFFFFF"
    var lineSpacing: CGFloat = 1.5
    var textAlignment: String = "left"
    var bionicReading: Bool = false
    var brightness: Double = -1 // -1 means use system
    
    // TTS Settings
    var ttsEnabled: Bool = false
    var ttsRate: Float = 0.5
    var ttsPitch: Float = 1.0
    var ttsVoice: String?
    
    // Translation Settings
    var translationEnabled: Bool = false
    var sourceLanguage: String?
    var targetLanguage: String?
}

// MARK: - App Settings
struct AppSettings: Codable {
    var downloadFolder: String = "QuickNovel/Downloads"
    var autoDownloadChapters: Bool = false
    var downloadWifiOnly: Bool = true
    var maxConcurrentDownloads: Int = 3
    var cacheSize: Int = 100 // MB
    var defaultProvider: String?
}
