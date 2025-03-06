//
//  BookAPIResponse.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import Foundation

struct BookAPIResponse: Codable {
    let title: String
    let authors: [String]
    let publishedDate: String?
    let description: String?
    let imageLinks: ImageLinks?
    let categories: [String]?
    
    struct ImageLinks: Codable {
        let thumbnail: String?
        let smallThumbnail: String?
    }
}

class ISBNLookupService {
    static let shared = ISBNLookupService()
    private let baseURL = "https://www.googleapis.com/books/v1/volumes?q=isbn:"
    
    func lookupBook(isbn: String) async throws -> Book {
        let url = URL(string: baseURL + isbn)!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct Response: Codable {
            let items: [Item]?
            
            struct Item: Codable {
                let volumeInfo: BookAPIResponse
            }
        }
        
        let response = try JSONDecoder().decode(Response.self, from: data)
        guard let bookInfo = response.items?.first?.volumeInfo else {
            throw NSError(domain: "BookLookup", code: 404, userInfo: [NSLocalizedDescriptionKey: "Book not found"])
        }
        
        return Book(
            title: bookInfo.title,
            author: bookInfo.authors.first ?? "Unknown Author",
            isbn: isbn,
            coverUrl: URL(string: bookInfo.imageLinks?.thumbnail ?? ""),
            genres: Set(bookInfo.categories ?? []),
            notes: bookInfo.description
        )
    }
} 