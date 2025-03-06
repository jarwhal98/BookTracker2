import Foundation

enum ReadingStatus: String, Codable, CaseIterable {
    case toRead = "To Read"
    case currentlyReading = "Currently Reading"
    case completed = "Completed"
    
    var displayName: String {
        self.rawValue
    }
}
