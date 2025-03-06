import Foundation

extension Calendar {
    func daysLeftInYear(from date: Date = Date()) -> Int? {
        guard let endOfYear = self.date(from: DateComponents(
            year: component(.year, from: date),
            month: 12,
            day: 31
        )) else { return nil }
        
        return dateComponents([.day], from: date, to: endOfYear).day
    }
} 