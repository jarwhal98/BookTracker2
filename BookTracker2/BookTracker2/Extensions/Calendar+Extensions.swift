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
    
    func daysSinceStartOfYear() -> Int? {
        let now = Date()
        let startOfYear = self.date(from: DateComponents(year: self.component(.year, from: now)))!
        return self.dateComponents([.day], from: startOfYear, to: now).day
    }
    
    func daysInYear() -> Int? {
        let now = Date()
        let year = self.component(.year, from: now)
        let startOfYear = self.date(from: DateComponents(year: year))!
        let startOfNextYear = self.date(from: DateComponents(year: year + 1))!
        return self.dateComponents([.day], from: startOfYear, to: startOfNextYear).day
    }
}
