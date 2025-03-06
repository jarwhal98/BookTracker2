//
//  YearlyStats.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import Foundation

struct YearlyStats {
    let readingGoal: YearlyGoal?
    let genreDistribution: [GenreStat]
    let monthlyBooks: [MonthStat]
    let ratingDistribution: [RatingStat]
}

struct GenreStat {
    let genre: String
    let count: Int
}

struct MonthStat {
    let month: String
    let count: Int
}

struct RatingStat {
    let rating: String
    let count: Int
} 