//
//  ReadingGoal.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import Foundation

struct ReadingGoal: Codable {
    let year: Int
    var targetBooks: Int
    var completedBooks: Int
    
    var isSet: Bool {
        targetBooks > 0
    }
    
    var percentageCompleted: Double {
        guard targetBooks > 0 else { return 0 }
        return (Double(completedBooks) / Double(targetBooks)) * 100
    }
    
    var remainingBooks: Int {
        guard targetBooks > 0 else { return 0 }
        return targetBooks - completedBooks
    }
    
    var daysPerBookRequired: Double? {
        guard targetBooks > 0 && remainingBooks > 0,
              let daysLeft = Calendar.current.daysLeftInYear() else { 
            return nil 
        }
        return Double(daysLeft) / Double(remainingBooks)
    }
    
    var expectedBooksAtThisPoint: Double {
        guard let daysPassed = Calendar.current.daysSinceStartOfYear(),
              let totalDays = Calendar.current.daysInYear() else { return 0 }
        return Double(targetBooks) * (Double(daysPassed) / Double(totalDays))
    }
    
    var booksAheadOfSchedule: Double {
        Double(completedBooks) - expectedBooksAtThisPoint
    }
    
    var isAheadOfSchedule: Bool {
        booksAheadOfSchedule > 0
    }
    
    var currentPace: Double? {
        guard let daysPassed = Calendar.current.daysSinceStartOfYear(),
              daysPassed > 0 else { return nil }
        return (Double(completedBooks) / Double(daysPassed)) * 365
    }
} 