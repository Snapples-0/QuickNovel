//
//  NovelFullProvider.swift
//  QuickNovel
//

import Foundation

class NovelFullProvider: NovelProvider {
    let name = "NovelFull"
    let baseUrl = "https://novelfull.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse, .download]
    
    func search(query: String) async throws -> [SearchResponse] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchUrl = "\(baseUrl)/search?keyword=\(encodedQuery)"
        let html = try await NetworkManager.shared.fetchHTML(from: searchUrl)
        return try parseSearchResults(html: html)
    }
    
    func load(url: String) async throws -> LoadResponse {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return try parseNovelDetails(html: html, url: url)
    }
    
    func loadMainPage(page: Int, category: String?, orderBy: String?, tag: String?) async throws -> MainPageResponse {
        let pageUrl = "\(baseUrl)/latest-release-novel?page=\(page)"
        let html = try await NetworkManager.shared.fetchHTML(from: pageUrl)
        let results = try parseSearchResults(html: html)
        return MainPageResponse(apiName: name, results: results)
    }
    
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
    
    private func parseSearchResults(html: String) throws -> [SearchResponse] {
        // Simplified parsing - would use SwiftSoup in production
        return []
    }
    
    private func parseNovelDetails(html: String, url: String) throws -> StreamResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil, 
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
}

class NovelBinProvider: NovelProvider {
    let name = "NovelBin"
    let baseUrl = "https://novelbin.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchUrl = "\(baseUrl)/search?keyword=\(encodedQuery)"
        let html = try await NetworkManager.shared.fetchHTML(from: searchUrl)
        return []
    }
    
    func load(url: String) async throws -> LoadResponse {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class ScribbleHubProvider: NovelProvider {
    let name = "ScribbleHub"
    let baseUrl = "https://www.scribblehub.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse, .reviews]
    
    func search(query: String) async throws -> [SearchResponse] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchUrl = "\(baseUrl)/series-finder/?sf=1&tgi=0&sort=sdate&order=desc&rl=0&status=0&ge=0&mge=0&tf=0&tt=0&chp=0&ss=0&gep=&gi=&ge_op=&mgi=&mg_op=&ti=\(encodedQuery)"
        let html = try await NetworkManager.shared.fetchHTML(from: searchUrl)
        return []
    }
    
    func load(url: String) async throws -> LoadResponse {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

// Additional simplified providers
class ReadNovelFullProvider: NovelProvider {
    let name = "ReadNovelFull"
    let baseUrl = "https://readnovelfull.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class BestLightNovelProvider: NovelProvider {
    let name = "BestLightNovel"
    let baseUrl = "https://bestlightnovel.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class FreeWebNovelProvider: NovelProvider {
    let name = "FreeWebNovel"
    let baseUrl = "https://freewebnovel.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class LibReadProvider: NovelProvider {
    let name = "LibRead"
    let baseUrl = "https://libread.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class AllNovelProvider: NovelProvider {
    let name = "AllNovel"
    let baseUrl = "https://allnovel.org"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class NovelsOnlineProvider: NovelProvider {
    let name = "NovelsOnline"
    let baseUrl = "https://novelsonline.org"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class ReadFromNetProvider: NovelProvider {
    let name = "ReadFromNet"
    let baseUrl = "https://readfrom.net"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class AnnasArchiveProvider: NovelProvider {
    let name = "AnnasArchive"
    let baseUrl = "https://annas-archive.org"
    let supportedFeatures: [ProviderFeature] = [.search, .epub]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return EpubResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                          synopsis: nil, tags: nil, author: nil, epubUrl: url, apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        throw ProviderError.notSupported
    }
}

class MtlNovelProvider: NovelProvider {
    let name = "MtlNovel"
    let baseUrl = "https://www.mtlnovels.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class KolNovelProvider: NovelProvider {
    let name = "KolNovel"
    let baseUrl = "https://kolnovel.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class MeioNovelProvider: NovelProvider {
    let name = "MeioNovel"
    let baseUrl = "https://meionovels.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class GraycityProvider: NovelProvider {
    let name = "Graycity"
    let baseUrl = "https://graycity.net"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class IndoWebNovelProvider: NovelProvider {
    let name = "IndoWebNovel"
    let baseUrl = "https://indowebnovel.id"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class SakuraNovelProvider: NovelProvider {
    let name = "SakuraNovel"
    let baseUrl = "https://sakuranovel.id"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class PawReadProvider: NovelProvider {
    let name = "PawRead"
    let baseUrl = "https://pawread.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class WtrLabProvider: NovelProvider {
    let name = "WtrLab"
    let baseUrl = "https://wtr-lab.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class HiraethTranslationProvider: NovelProvider {
    let name = "HiraethTranslation"
    let baseUrl = "https://hiraethtranslation.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}

class RisenNovelProvider: NovelProvider {
    let name = "RisenNovel"
    let baseUrl = "https://risenovel.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse]
    
    func search(query: String) async throws -> [SearchResponse] { return [] }
    func load(url: String) async throws -> LoadResponse {
        return StreamResponse(name: "Novel", url: url, posterUrl: nil, rating: nil,
                            synopsis: nil, tags: nil, author: nil, data: [], apiName: name)
    }
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        return ChapterContent(url: url, html: html, plainText: HTMLParser.htmlToPlainText(html))
    }
}
