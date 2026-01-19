//
//  NetworkManager.swift
//  QuickNovel
//
//  Network layer with caching and error handling
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let cache = NSCache<NSString, CachedResponse>()
    private let cacheTimeout: TimeInterval = 600 // 10 minutes
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Set user agent
        configuration.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        ]
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Fetch HTML
    func fetchHTML(from urlString: String, headers: [String: String]? = nil) async throws -> String {
        // Check cache first
        if let cached = cache.object(forKey: urlString as NSString),
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout {
            return cached.html
        }
        
        guard let url = URL(string: urlString) else {
            throw ProviderError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add custom headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProviderError.networkError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 429 {
                throw ProviderError.rateLimit
            } else if httpResponse.statusCode == 403 {
                throw ProviderError.cloudflareBlocked
            }
            throw ProviderError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw ProviderError.parsingError("Unable to decode response as UTF-8")
        }
        
        // Cache the response
        let cached = CachedResponse(html: html, timestamp: Date())
        cache.setObject(cached, forKey: urlString as NSString)
        
        return html
    }
    
    // MARK: - Fetch JSON
    func fetchJSON<T: Decodable>(from urlString: String, headers: [String: String]? = nil) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw ProviderError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProviderError.networkError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ProviderError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Download File
    func downloadFile(from urlString: String, to destinationURL: URL, progress: @escaping (Double) -> Void) async throws {
        guard let url = URL(string: urlString) else {
            throw ProviderError.invalidUrl
        }
        
        let (asyncBytes, response) = try await session.bytes(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProviderError.networkError("Failed to download file")
        }
        
        let expectedLength = httpResponse.expectedContentLength
        var downloadedData = Data()
        
        // Reserve capacity for better performance
        if expectedLength > 0 {
            downloadedData.reserveCapacity(Int(expectedLength))
        }
        
        for try await byte in asyncBytes {
            downloadedData.append(byte)
            if expectedLength > 0 {
                let progressValue = Double(downloadedData.count) / Double(expectedLength)
                progress(progressValue)
            }
        }
        
        try downloadedData.write(to: destinationURL)
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Cached Response
private class CachedResponse {
    let html: String
    let timestamp: Date
    
    init(html: String, timestamp: Date) {
        self.html = html
        self.timestamp = timestamp
    }
}

// MARK: - HTML Parser Helper
struct HTMLParser {
    static func extractText(from html: String, selector: String) -> String? {
        // Basic HTML text extraction (would use SwiftSoup in production)
        // This is a simplified version
        return nil
    }
    
    static func extractElements(from html: String, selector: String) -> [String] {
        // Would use SwiftSoup for proper parsing
        return []
    }
    
    static func cleanHTML(_ html: String) -> String {
        var cleaned = html
        
        // Remove script tags
        cleaned = cleaned.replacingOccurrences(of: "<script[^>]*>.*?</script>", with: "", options: .regularExpression, range: nil)
        
        // Remove style tags
        cleaned = cleaned.replacingOccurrences(of: "<style[^>]*>.*?</style>", with: "", options: .regularExpression, range: nil)
        
        return cleaned
    }
    
    static func htmlToPlainText(_ html: String) -> String {
        var text = html
        
        // Replace <br> and <p> with newlines
        text = text.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</p>", with: "\n\n", options: .regularExpression)
        
        // Remove all HTML tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Decode HTML entities
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
