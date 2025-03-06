//
//  DataPersistence.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import Foundation

class DataPersistence {
    private static let booksKey = "savedBooks"
    private static let readingGoalKey = "readingGoal"
    private static let genresKey = "genres"
    private static let yearlyGoalsKey = "yearlyGoals"
    
    static func saveBooks(_ books: [Book]) {
        do {
            let data = try JSONEncoder().encode(books)
            UserDefaults.standard.set(data, forKey: booksKey)
        } catch {
            print("Error saving books: \(error)")
        }
    }
    
    static func loadBooks() -> [Book] {
        guard let data = UserDefaults.standard.data(forKey: booksKey) else {
            return []
        }
        
        do {
            let books = try JSONDecoder().decode([Book].self, from: data)
            return books
        } catch {
            print("Error loading books: \(error)")
            return []
        }
    }
    
    static func saveReadingGoal(_ goal: ReadingGoal) {
        if let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: readingGoalKey)
        }
    }
    
    static func loadReadingGoal() -> ReadingGoal? {
        guard let data = UserDefaults.standard.data(forKey: readingGoalKey),
              let goal = try? JSONDecoder().decode(ReadingGoal.self, from: data) else {
            return nil
        }
        return goal
    }
    
    static func saveGenres(_ genres: Set<String>) {
        UserDefaults.standard.set(Array(genres), forKey: genresKey)
    }
    
    static func loadGenres() -> Set<String> {
        let genres = UserDefaults.standard.stringArray(forKey: genresKey) ?? []
        return Set(genres)
    }
    
    static func saveYearlyGoals(_ goals: [YearlyGoal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: yearlyGoalsKey)
        }
    }
    
    static func loadYearlyGoals() -> [YearlyGoal] {
        if let data = UserDefaults.standard.data(forKey: yearlyGoalsKey),
           let goals = try? JSONDecoder().decode([YearlyGoal].self, from: data) {
            return goals
        }
        return []
    }
} 