//
//  MainTabView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = BookTrackerViewModel()
    @State private var selectedTab = 0
    @State private var showingGoalCompletion = false
    
    var body: some View {
        Group {
            if !viewModel.readingGoal.isSet {
                SetupGoalView(viewModel: viewModel)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView(viewModel: viewModel)
                        .tabItem {
                            Label("Home", systemImage: "book.fill")
                        }
                        .tag(0)
                    
                    BookshelfView(viewModel: viewModel)
                        .tabItem {
                            Label("Bookshelf", systemImage: "books.vertical.fill")
                        }
                        .tag(1)
                    
                    StatsView(viewModel: viewModel)
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }
                        .tag(2)
                }
                .onChange(of: viewModel.readingGoal.completedBooks) { oldValue, newValue in
                    if newValue == viewModel.readingGoal.targetBooks {
                        showingGoalCompletion = true
                    }
                }
                .sheet(isPresented: $showingGoalCompletion) {
                    GoalCompletionView(goal: viewModel.readingGoal)
                }
            }
        }
        .tint(.blue)
    }
}

// Add this extension to format the year without commas
extension Int {
    var yearString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
} 