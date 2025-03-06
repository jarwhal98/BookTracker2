import Foundation

class BookSearchService {
    static let shared = BookSearchService()
    private init() {}
    
    private let baseURL = "https://openlibrary.org"
    
    func searchBooks(query: String) async throws -> [SearchResult] {
        // Only treat as ISBN if it matches ISBN format (10 or 13 digits, possibly with hyphens)
        let cleanQuery = query.replacingOccurrences(of: "-", with: "")
        if cleanQuery.count >= 10 && cleanQuery.allSatisfy({ $0.isNumber }) {
            if let result = try await searchByISBN(isbn: cleanQuery) {
                return [result]
            }
            return []
        }
        
        // Use the works API for regular searches
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search.json?q=\(encodedQuery)&limit=10"  // Simplified search endpoint
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        print("Searching with URL: \(urlString)")  // Debug print
        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResponse = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
        
        print("Found \(searchResponse.docs.count) results")  // Debug print
        
        return searchResponse.docs.compactMap { doc in
            guard let title = doc.title,
                  let author = doc.author_name?.first else { 
                print("Skipping result due to missing title or author")  // Debug print
                return nil 
            }
            
            let coverID = doc.cover_i
            let coverUrl = coverID != nil ? URL(string: "https://covers.openlibrary.org/b/id/\(coverID!)-L.jpg") : nil
            
            let result = SearchResult(
                title: title,
                author: author,
                isbn: doc.isbn?.first ?? "",
                coverUrl: coverUrl,
                publishedDate: nil,
                isForSale: false
            )
            print("Created result: \(result.title) by \(result.author)")  // Debug print
            return result
        }
    }
    
    private func searchByISBN(isbn: String) async throws -> SearchResult? {
        let cleanISBN = isbn.replacingOccurrences(of: "-", with: "")
        let urlString = "\(baseURL)/isbn/\(cleanISBN).json"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let bookDetail = try JSONDecoder().decode(OpenLibraryISBNResponse.self, from: data)
        
        var authorName = "Unknown Author"
        if let authorKey = bookDetail.authors?.first?.key {
            authorName = try await fetchAuthorName(authorKey: authorKey)
        }
        
        return SearchResult(
            title: bookDetail.title,
            author: authorName,
            isbn: cleanISBN,
            coverUrl: bookDetail.covers?.first.map { URL(string: "https://covers.openlibrary.org/b/id/\($0)-L.jpg") } ?? nil,
            publishedDate: nil,
            isForSale: false
        )
    }
    
    private func fetchAuthorName(authorKey: String) async throws -> String {
        let urlString = "\(baseURL)\(authorKey).json"
        guard let url = URL(string: urlString) else {
            return "Unknown Author"
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let author = try JSONDecoder().decode(OpenLibraryAuthorResponse.self, from: data)
        return author.name
    }
}

// Response models for Open Library API
struct OpenLibrarySearchResponse: Codable {
    let docs: [OpenLibraryDoc]
}

struct OpenLibraryDoc: Codable {
    let key: String?
    let title: String?
    let author_name: [String]?
    let isbn: [String]?
    let cover_i: Int?
}

struct OpenLibraryISBNResponse: Codable {
    let key: String
    let title: String
    let authors: [OpenLibraryAuthorReference]?
    let covers: [Int]?
}

struct OpenLibraryAuthorReference: Codable {
    let key: String
}

struct OpenLibraryAuthorResponse: Codable {
    let name: String
}

struct OpenLibraryCover: Codable {
    let small: String?
    let medium: String?
    let large: String?
} 