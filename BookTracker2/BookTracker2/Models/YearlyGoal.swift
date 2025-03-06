import Foundation

struct YearlyGoal: Identifiable, Codable {
    var id: UUID
    var year: Int
    var targetBooks: Int
    var completedBooks: Int
    
    init(
        id: UUID = UUID(),
        year: Int,
        targetBooks: Int,
        completedBooks: Int = 0
    ) {
        self.id = id
        self.year = year
        self.targetBooks = targetBooks
        self.completedBooks = completedBooks
    }
}
