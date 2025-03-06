//
//  StatsView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: BookTrackerViewModel
    @State private var selectedYear: Int
    @State private var showingGoalSheet = false
    @State private var showingYearEndSummary = false
    
    var theme: AppTheme { viewModel.themeManager.currentTheme }
    
    init(viewModel: BookTrackerViewModel) {
        self.viewModel = viewModel
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }
    
    var yearlyStats: YearlyStats {
        let stats = viewModel.getStatsForYear(selectedYear)
        let goal = viewModel.getGoalForYear(selectedYear)
        return YearlyStats(
            readingGoal: goal,
            genreDistribution: stats.genreDistribution,
            monthlyBooks: stats.monthlyBooks,
            ratingDistribution: stats.ratingDistribution
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Year Picker
                    Picker("Year", selection: $selectedYear) {
                        ForEach(viewModel.availableYears, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Reading Progress
                    ProgressCard(goal: yearlyStats.readingGoal, theme: theme) {
                        showingGoalSheet = true
                    }
                    
                    // Genre Distribution
                    GenreDistributionCard(genres: yearlyStats.genreDistribution, theme: theme)
                    
                    // Monthly Reading Chart
                    MonthlyReadingCard(monthlyBooks: yearlyStats.monthlyBooks, theme: theme)
                    
                    // Rating Distribution
                    RatingDistributionCard(ratings: yearlyStats.ratingDistribution, theme: theme)
                    
                    // Year Summary Button
                    Button(action: { showingYearEndSummary = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("View Year Summary")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(theme.primary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Reading Insights")
                        .font(.system(size: 38, design: .rounded))
                        .fontWeight(.light)
                        .foregroundColor(Color(hex: "8B4513"))
                }
            }
            .sheet(isPresented: $showingGoalSheet) {
                GoalSettingView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingYearEndSummary) {
                YearEndSummaryView(
                    summary: viewModel.generateYearEndSummary(for: selectedYear),
                    theme: theme
                )
            }
        }
    }
}

struct GenreDistributionCard: View {
    let genres: [GenreStat]
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Most Read Genres")
                .font(.headline)
                .foregroundColor(theme.text)
            
            Chart(genres, id: \.genre) { item in
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Genre", item.genre)
                )
                .foregroundStyle(theme.primary.gradient)
            }
            .frame(height: CGFloat(genres.count * 40))
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct MonthlyReadingCard: View {
    let monthlyBooks: [MonthStat]
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Books Read by Month")
                .font(.headline)
                .foregroundColor(theme.text)
            
            Chart(monthlyBooks, id: \.month) { item in
                BarMark(
                    x: .value("Month", item.month),
                    y: .value("Books", item.count)
                )
                .foregroundStyle(theme.primary.gradient)
            }
            .frame(height: 200)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct RatingDistributionCard: View {
    let ratings: [RatingStat]
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rating Distribution")
                .font(.headline)
                .foregroundColor(theme.text)
            
            Chart(ratings, id: \.rating) { item in
                BarMark(
                    x: .value("Rating", item.rating),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(theme.secondary.gradient)
            }
            .frame(height: 200)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
} 