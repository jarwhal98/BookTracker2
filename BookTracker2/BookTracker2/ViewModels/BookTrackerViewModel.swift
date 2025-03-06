//
//  BookTrackerViewModel.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import Foundation
import SwiftUI

class BookTrackerViewModel: ObservableObject {
    @Published private(set) var books: [Book] = []
    @Published var readingGoal: ReadingGoal
    @Published private(set) var historicalGoals: [YearlyGoal] = []
    @Published var availableGenres: Set<String>
    @Published var themeManager = ThemeManager()
    
    private let defaultGenres = Set(["Fiction", "Non-Fiction", "Mystery", "Science Fiction", "Fantasy", "Biography", "Self-Help"])
    
    var currentlyReadingBooks: [Book] {
        books.filter { $0.status == .currentlyReading }
    }
    
    var readBooks: [Book] {
        books.filter { $0.status == .completed }
    }
    
    var toReadBooks: [Book] {
        books.filter { $0.status == .toRead }
    }
    
    init() {
        // Initialize with current year
        let currentYear = Calendar.current.component(.year, from: Date())
        self.readingGoal = ReadingGoal(
            year: currentYear,
            targetBooks: 0,
            completedBooks: 0
        )
        self.availableGenres = ["Fiction", "Non-Fiction", "Mystery", "Science Fiction", "Fantasy", "Biography", "Self-Help"]
        
        // Load saved data
        loadData()
        
        // Migrate old data if needed
        migrateOldGoals()
        
        // Set up year change observer
        setupYearChangeObserver()
    }
    
    private func migrateOldGoals() {
        // Check if we've already migrated
        let hasMigrated = UserDefaults.standard.bool(forKey: "hasPerformedGoalMigration")
        guard !hasMigrated else { return }
        
        // Find all completed books from previous years
        let booksByYear = Dictionary(grouping: books) { book -> Int in
            if let date = book.dateCompleted {
                return Calendar.current.component(.year, from: date)
            }
            return Calendar.current.component(.year, from: Date())
        }
        
        // Create historical goals for each year
        for (year, yearBooks) in booksByYear {
            if year != readingGoal.year {  // Don't create historical goal for current year
                let completedCount = yearBooks.filter { $0.status == .completed }.count
                let historicalGoal = YearlyGoal(
                    year: year,
                    targetBooks: readingGoal.targetBooks,  // Use current target as estimate
                    completedBooks: completedCount
                )
                if !historicalGoals.contains(where: { $0.year == year }) {
                    historicalGoals.append(historicalGoal)
                }
            }
        }
        
        // Mark migration as complete
        UserDefaults.standard.set(true, forKey: "hasPerformedGoalMigration")
        saveData()
    }
    
    private func setupYearChangeObserver() {
        Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let newYear = Calendar.current.component(.year, from: Date())
            if newYear != self.readingGoal.year {
                // Archive current goal
                let oldGoal = YearlyGoal(
                    year: self.readingGoal.year,
                    targetBooks: self.readingGoal.targetBooks,
                    completedBooks: self.readingGoal.completedBooks
                )
                self.historicalGoals.append(oldGoal)
                
                // Create new goal for new year
                self.readingGoal = ReadingGoal(
                    year: newYear,
                    targetBooks: self.readingGoal.targetBooks,
                    completedBooks: 0
                )
                self.saveData()
            }
        }
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        if book.status == .completed {
            // Only count towards goal if completed this year
            if let dateCompleted = book.dateCompleted,
               Calendar.current.component(.year, from: dateCompleted) == readingGoal.year {
                readingGoal.completedBooks += 1
            }
        }
        saveData()
    }
    
    func updateBookStatus(_ book: Book, to status: ReadingStatus) {
        var updatedBook = book
        updatedBook.status = status
        
        // Preserve the cover URL when updating the book
        print("Updating book status for '\(book.title)'")
        print("Original cover URL: \(String(describing: book.coverUrl))")
        print("Updated cover URL: \(String(describing: updatedBook.coverUrl))")
        
        // Update completion date if needed
        if status == .completed && book.status != .completed {
            updatedBook.dateCompleted = Date()
            
            // Update yearly goal progress
            let currentYear = Calendar.current.component(.year, from: Date())
            if let yearlyGoal = historicalGoals.first(where: { $0.year == currentYear }) {
                let updatedGoal = YearlyGoal(
                    year: yearlyGoal.year,
                    targetBooks: yearlyGoal.targetBooks,
                    completedBooks: yearlyGoal.completedBooks + 1
                )
                if let index = historicalGoals.firstIndex(where: { $0.year == currentYear }) {
                    historicalGoals[index] = updatedGoal
                }
                saveData()
            }
        } else if status != .completed {
            updatedBook.dateCompleted = nil
            updatedBook.rating = nil
        }
        
        updateBook(updatedBook)
    }
    
    private func loadData() {
        books = DataPersistence.loadBooks()
        historicalGoals = DataPersistence.loadYearlyGoals()
        
        if let savedGoal = DataPersistence.loadReadingGoal() {
            readingGoal = savedGoal
        }
        
        let savedGenres = DataPersistence.loadGenres()
        if !savedGenres.isEmpty {
            availableGenres = savedGenres
        }
    }
    
    private func saveData() {
        DataPersistence.saveBooks(books)
        DataPersistence.saveReadingGoal(readingGoal)
        DataPersistence.saveGenres(availableGenres)
        DataPersistence.saveYearlyGoals(historicalGoals)
    }
    
    var availableYears: [Int] {
        var years = Set<Int>()
        
        // Add current year
        years.insert(Calendar.current.component(.year, from: Date()))
        
        // Add years from completed books
        books.compactMap { book -> Int? in
            guard let date = book.dateCompleted else { return nil }
            return Calendar.current.component(.year, from: date)
        }.forEach { years.insert($0) }
        
        // Add years from historical goals
        historicalGoals.forEach { years.insert($0.year) }
        
        return Array(years).sorted(by: >)
    }
    
    func getStatsForYear(_ year: Int) -> YearlyStats {
        let booksInYear = books.filter { book in
            guard let date = book.dateCompleted else { return false }
            return Calendar.current.component(.year, from: date) == year
        }
        
        // Genre distribution
        var genreCounts: [String: Int] = [:]
        for book in booksInYear {
            for genre in book.genres {
                genreCounts[genre, default: 0] += 1
            }
        }

        // Convert dictionary to array of GenreStat
        var genreStats: [GenreStat] = []
        for (genre, count) in genreCounts {
            genreStats.append(GenreStat(genre: genre, count: count))
        }

        // Sort the array
        let genreDistribution = genreStats.sorted { $0.count > $1.count }
        
        // Monthly distribution
        var monthCounts: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for book in booksInYear {
            guard let date = book.dateCompleted else { continue }
            let month = dateFormatter.string(from: date)
            monthCounts[month, default: 0] += 1
        }
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let monthlyBooks = months.map { month in
            MonthStat(month: month, count: monthCounts[month] ?? 0)
        }
        
        // Rating distribution
        var ratingCounts: [String: Int] = [:]
        for book in booksInYear {
            guard let rating = book.rating else { continue }
            let ratingStr = String(format: "%.1f", rating)
            ratingCounts[ratingStr, default: 0] += 1
        }
        let ratingDistribution = ratingCounts.map {
            RatingStat(rating: $0.key, count: $0.value)
        }.sorted { $0.rating < $1.rating }
        
        return YearlyStats(
            readingGoal: getGoalForYear(year),
            genreDistribution: genreDistribution,
            monthlyBooks: monthlyBooks,
            ratingDistribution: ratingDistribution
        )
    }
    
    func updateTheme(_ theme: AppTheme) {
        themeManager.currentTheme = theme
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            
            // Update reading goal count
            readingGoal.completedBooks = books.filter { book in
                book.status == .completed && 
                (book.dateCompleted.map { Calendar.current.component(.year, from: $0) } ?? 0) == readingGoal.year
            }.count
            
            // Save changes
            saveData()
        }
    }
    
    func addNewGenre(_ genre: String) {
        availableGenres.insert(genre)
        saveData()  // This will persist the new genre
    }
    
    func updateReadingGoal(targetBooks: Int) {
        readingGoal = ReadingGoal(
            year: readingGoal.year,
            targetBooks: targetBooks,
            completedBooks: readingGoal.completedBooks
        )
        saveData()
    }
    
    func deleteBook(_ book: Book) {
        print("Deleting book: \(book.title)")
        print("Book status: \(book.status)")
        print("Book completion date: \(String(describing: book.dateCompleted))")
        
        // First, check if this book was completed in the current year
        if let dateCompleted = book.dateCompleted,
           book.status == .completed {
            let currentYear = Calendar.current.component(.year, from: Date())
            let completedYear = Calendar.current.component(.year, from: dateCompleted)
            
            print("Current year: \(currentYear)")
            print("Completed year: \(completedYear)")
            
            if completedYear == currentYear {
                print("Book was completed this year")
                // Update the current reading goal
                readingGoal.completedBooks = max(0, readingGoal.completedBooks - 1)
            } else {
                // Update historical goals
                if let index = historicalGoals.firstIndex(where: { $0.year == completedYear }) {
                    historicalGoals[index].completedBooks = max(0, historicalGoals[index].completedBooks - 1)
                }
            }
            
            // Save the updated goals
            saveData()
        }
        
        // Remove the book from the collection
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books.remove(at: index)
            saveData()
        }
    }
    
    // Add this helper method
    private func calculateProgressForYear(_ year: Int) -> Int {
        return books.filter { book in
            guard book.status == .completed,
                  let completionDate = book.dateCompleted else { return false }
            return Calendar.current.component(.year, from: completionDate) == year
        }.count
    }
    
    func getGoalForYear(_ year: Int) -> YearlyGoal? {
        if year == readingGoal.year {
            return YearlyGoal(
                year: readingGoal.year,
                targetBooks: readingGoal.targetBooks,
                completedBooks: readingGoal.completedBooks
            )
        }
        return historicalGoals.first { $0.year == year }
    }
    
    // Add year-end stats functionality
    func generateYearEndSummary(for year: Int) -> YearEndSummary {
        let stats = getStatsForYear(year)
        let goal = getGoalForYear(year)
        
        let booksInYear = books.filter { book in
            guard let date = book.dateCompleted else { return false }
            return Calendar.current.component(.year, from: date) == year
        }
        
        let averageRating = booksInYear.compactMap { $0.rating }.reduce(0.0, +) / 
            Double(booksInYear.compactMap { $0.rating }.count)
        
        let longestStreak = calculateReadingStreak(in: booksInYear)
        
        let mostReadAuthor = findMostReadAuthor(in: booksInYear)
        
        return YearEndSummary(
            year: year,
            totalBooksRead: booksInYear.count,
            goalAchieved: goal?.completedBooks ?? 0 >= goal?.targetBooks ?? 0,
            averageRating: averageRating,
            longestReadingStreak: longestStreak,
            mostReadAuthor: mostReadAuthor,
            topGenres: stats.genreDistribution.map { (genre: $0.genre, count: $0.count) },
            bestRatedBook: booksInYear.max(by: { ($0.rating ?? 0) < ($1.rating ?? 0) }),
            mostProductiveMonth: stats.monthlyBooks.max(by: { $0.count < $1.count })
        )
    }
    
    private func calculateReadingStreak(in books: [Book]) -> Int {
        let sortedDates = books.compactMap { $0.dateCompleted }
            .sorted()
        
        var currentStreak = 1
        var maxStreak = 1
        
        for i in 1..<sortedDates.count {
            let daysBetween = Calendar.current.dateComponents(
                [.day],
                from: sortedDates[i-1],
                to: sortedDates[i]
            ).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    private func findMostReadAuthor(in books: [Book]) -> (author: String, count: Int)? {
        let authorCounts = Dictionary(grouping: books, by: { $0.author })
            .mapValues { $0.count }
        
        return authorCounts.max(by: { $0.value < $1.value })
            .map { ($0.key, $0.value) }
    }
    
    func isGenreInUse(_ genre: String) -> Int {
        books.filter { $0.genres.contains(genre) }.count
    }
    
    func isCustomGenre(_ genre: String) -> Bool {
        !defaultGenres.contains(genre)
    }
    
    func deleteGenre(_ genre: String) {
        guard isCustomGenre(genre) else { return }  // Only allow deleting custom genres
        availableGenres.remove(genre)
        saveData()
    }
}

// Add this struct to Models/Book.swift
struct YearEndSummary {
    let year: Int
    let totalBooksRead: Int
    let goalAchieved: Bool
    let averageRating: Double
    let longestReadingStreak: Int
    let mostReadAuthor: (author: String, count: Int)?
    let topGenres: [(genre: String, count: Int)]
    let bestRatedBook: Book?
    let mostProductiveMonth: MonthStat?
} 
