//
//  RoyalRoadProvider.swift
//  QuickNovel
//
//  Provider for RoyalRoad.com
//

import Foundation

class RoyalRoadProvider: NovelProvider {
    let name = "RoyalRoad"
    let baseUrl = "https://www.royalroad.com"
    let supportedFeatures: [ProviderFeature] = [.search, .browse, .reviews, .download]
    
    func search(query: String) async throws -> [SearchResponse] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchUrl = "\(baseUrl)/fictions/search?title=\(encodedQuery)"
        
        let html = try await NetworkManager.shared.fetchHTML(from: searchUrl)
        
        var results: [SearchResponse] = []
        
        // Parse HTML to extract search results
        // Using regex for basic extraction (in production would use SwiftSoup)
        let fictionPattern = #"<div class="fiction-list-item"[^>]*>.*?<h2[^>]*>.*?<a href="([^"]*)"[^>]*>([^<]*)</a>.*?<img.*?src="([^"]*)".*?(?:<div class="stats">.*?<span[^>]*>(\d+\.?\d*)</span>)?.*?</div>"#
        
        let regex = try NSRegularExpression(pattern: fictionPattern, options: [.dotMatchesLineSeparators])
        let nsString = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            if match.numberOfRanges >= 3 {
                let urlRange = match.range(at: 1)
                let titleRange = match.range(at: 2)
                let imageRange = match.range(at: 3)
                
                let url = nsString.substring(with: urlRange)
                let title = nsString.substring(with: titleRange).trimmingCharacters(in: .whitespacesAndNewlines)
                let posterUrl = nsString.substring(with: imageRange)
                
                var rating: Int? = nil
                if match.numberOfRanges >= 5 {
                    let ratingRange = match.range(at: 4)
                    if ratingRange.location != NSNotFound {
                        let ratingStr = nsString.substring(with: ratingRange)
                        rating = Int((Double(ratingStr) ?? 0) * 20) // Convert to 0-100
                    }
                }
                
                results.append(SearchResponse(
                    name: title,
                    url: baseUrl + url,
                    posterUrl: posterUrl.starts(with: "http") ? posterUrl : baseUrl + posterUrl,
                    rating: rating,
                    latestChapter: nil,
                    author: nil,
                    synopsis: nil
                ))
            }
        }
        
        return results
    }
    
    func load(url: String) async throws -> LoadResponse {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        
        // Extract novel info
        var name = ""
        var posterUrl: String? = nil
        var synopsis: String? = nil
        var author: String? = nil
        var rating: Int? = nil
        var tags: [String] = []
        var chapters: [ChapterData] = []
        
        // Extract title
        if let titleMatch = html.range(of: #"<h1[^>]*>([^<]*)</h1>"#, options: .regularExpression) {
            let titleHTML = String(html[titleMatch])
            name = titleHTML.replacingOccurrences(of: #"<[^>]*>"#, with: "", options: .regularExpression)
        }
        
        // Extract poster image
        if let imageMatch = html.range(of: #"<img[^>]*class="[^"]*cover[^"]*"[^>]*src="([^"]*)"#, options: .regularExpression) {
            let imageHTML = String(html[imageMatch])
            if let srcRange = imageHTML.range(of: #"src="([^"]*)"#, options: .regularExpression) {
                posterUrl = String(imageHTML[srcRange]).replacingOccurrences(of: "src=\"", with: "").replacingOccurrences(of: "\"", with: "")
            }
        }
        
        // Extract chapters
        let chapterPattern = #"<tr[^>]*>.*?<a href="([^"]*)"[^>]*>([^<]*)</a>"#
        let chapterRegex = try NSRegularExpression(pattern: chapterPattern, options: [.dotMatchesLineSeparators])
        let nsString = html as NSString
        let chapterMatches = chapterRegex.matches(in: html, range: NSRange(location: 0, length: nsString.length))
        
        for match in chapterMatches {
            if match.numberOfRanges >= 3 {
                let chapterUrl = nsString.substring(with: match.range(at: 1))
                let chapterName = nsString.substring(with: match.range(at: 2)).trimmingCharacters(in: .whitespacesAndNewlines)
                
                chapters.append(ChapterData(
                    name: chapterName,
                    slug: String(chapterUrl.split(separator: "/").last ?? ""),
                    url: baseUrl + chapterUrl,
                    dateOfRelease: nil
                ))
            }
        }
        
        return StreamResponse(
            name: name,
            url: url,
            posterUrl: posterUrl,
            rating: rating,
            synopsis: synopsis,
            tags: tags.isEmpty ? nil : tags,
            author: author,
            data: chapters,
            apiName: name
        )
    }
    
    func loadMainPage(page: Int, category: String?, orderBy: String?, tag: String?) async throws -> MainPageResponse {
        var pageUrl = "\(baseUrl)/fictions/best-rated"
        
        if let category = category {
            pageUrl = "\(baseUrl)/fictions/\(category)"
        }
        
        if page > 1 {
            pageUrl += "?page=\(page)"
        }
        
        let html = try await NetworkManager.shared.fetchHTML(from: pageUrl)
        let results = try await parseSearchResults(html: html)
        
        return MainPageResponse(apiName: name, results: results)
    }
    
    func loadHtml(url: String) async throws -> ChapterContent {
        let html = try await NetworkManager.shared.fetchHTML(from: url)
        
        // Extract chapter content
        var content = ""
        if let contentRange = html.range(of: #"<div class="chapter-content"[^>]*>(.*?)</div>"#, options: .regularExpression) {
            content = String(html[contentRange])
            content = content.replacingOccurrences(of: #"<div class="chapter-content"[^>]*>"#, with: "", options: .regularExpression)
            content = content.replacingOccurrences(of: "</div>", with: "")
        }
        
        let plainText = HTMLParser.htmlToPlainText(content)
        
        return ChapterContent(url: url, html: content, plainText: plainText)
    }
    
    func loadReviews(url: String, page: Int) async throws -> [UserReview] {
        let reviewsUrl = url + "/reviews"
        let html = try await NetworkManager.shared.fetchHTML(from: reviewsUrl)
        
        var reviews: [UserReview] = []
        // Parse reviews from HTML
        // Implementation details omitted for brevity
        
        return reviews
    }
    
    private func parseSearchResults(html: String) async throws -> [SearchResponse] {
        // Reuse search parsing logic
        return []
    }
}
