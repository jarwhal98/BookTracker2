import Foundation

struct Book: Identifiable, Codable {
    var id: UUID
    var title: String
    var author: String
    var isbn: String
    var coverUrl: URL?
    var genres: Set<String>
    var rating: Double?
    var notes: String?
    var status: ReadingStatus
    var dateAdded: Date
    var dateCompleted: Date?
    var readCount: Int
    var isOwned: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        isbn: String,
        coverUrl: URL? = nil,
        genres: Set<String> = [],
        notes: String? = nil,
        status: ReadingStatus = .currentlyReading,
        dateAdded: Date = Date(),
        dateCompleted: Date? = nil,
        readCount: Int = 0,
        isOwned: Bool = true
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.coverUrl = coverUrl
        self.genres = genres
        self.notes = notes
        self.status = status
        self.dateAdded = dateAdded
        self.dateCompleted = dateCompleted
        self.readCount = readCount
        self.isOwned = isOwned
    }
}

