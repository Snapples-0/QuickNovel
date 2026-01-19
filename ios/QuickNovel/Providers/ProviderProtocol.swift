//
//  ProviderProtocol.swift
//  QuickNovel
//
//  Base protocol for all novel providers
//

import Foundation

// MARK: - Main Provider Protocol
protocol NovelProvider {
    var name: String { get }
    var baseUrl: String { get }
    var supportedFeatures: [ProviderFeature] { get }
    
    // Search for novels
    func search(query: String) async throws -> [SearchResponse]
    
    // Load novel details and chapters
    func load(url: String) async throws -> LoadResponse
    
    // Load main page/browse
    func loadMainPage(page: Int, category: String?, orderBy: String?, tag: String?) async throws -> MainPageResponse
    
    // Load chapter HTML content
    func loadHtml(url: String) async throws -> ChapterContent
    
    // Load reviews (optional)
    func loadReviews(url: String, page: Int) async throws -> [UserReview]
}

// MARK: - Default Implementation
extension NovelProvider {
    func loadMainPage(page: Int, category: String?, orderBy: String?, tag: String?) async throws -> MainPageResponse {
        throw ProviderError.notSupported
    }
    
    func loadReviews(url: String, page: Int) async throws -> [UserReview] {
        throw ProviderError.notSupported
    }
}

// MARK: - Provider Errors
enum ProviderError: LocalizedError {
    case invalidUrl
    case networkError(String)
    case parsingError(String)
    case notSupported
    case cloudflareBlocked
    case rateLimit
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Invalid URL provided"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Failed to parse response: \(message)"
        case .notSupported:
            return "This feature is not supported by this provider"
        case .cloudflareBlocked:
            return "Blocked by Cloudflare protection"
        case .rateLimit:
            return "Rate limit exceeded"
        }
    }
}

// MARK: - Provider Registry
class ProviderRegistry {
    static let shared = ProviderRegistry()
    private var providers: [NovelProvider] = []
    
    private init() {}
    
    func registerProvider(_ provider: NovelProvider) {
        providers.append(provider)
    }
    
    func getAllProviders() -> [NovelProvider] {
        return providers
    }
    
    func getProvider(byName name: String) -> NovelProvider? {
        return providers.first { $0.name == name }
    }
    
    func registerAllProviders() {
        // Register all available providers
        registerProvider(RoyalRoadProvider())
        registerProvider(ScribbleHubProvider())
        registerProvider(NovelFullProvider())
        registerProvider(NovelBinProvider())
        registerProvider(ReadNovelFullProvider())
        registerProvider(BestLightNovelProvider())
        registerProvider(FreeWebNovelProvider())
        registerProvider(LibReadProvider())
        registerProvider(AllNovelProvider())
        registerProvider(NovelsOnlineProvider())
        registerProvider(ReadFromNetProvider())
        registerProvider(AnnasArchiveProvider())
        registerProvider(MtlNovelProvider())
        registerProvider(KolNovelProvider())
        registerProvider(MeioNovelProvider())
        registerProvider(GraycityProvider())
        registerProvider(IndoWebNovelProvider())
        registerProvider(SakuraNovelProvider())
        registerProvider(PawReadProvider())
        registerProvider(WtrLabProvider())
        registerProvider(HiraethTranslationProvider())
        registerProvider(RisenNovelProvider())
        // Add more providers as they are implemented
    }
}
