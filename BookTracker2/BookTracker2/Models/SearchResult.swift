import Foundation

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let isbn: String?
    let coverUrl: URL?
    let publishedDate: String?
    let isForSale: Bool?
} 