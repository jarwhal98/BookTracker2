//
//  HomeView_backup.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct HomeView_Backup: View {
    @ObservedObject var viewModel: BookTrackerViewModel
    @State private var showingAddBook = false
    @State private var showingGoalSheet = false
    
    var theme: AppTheme { viewModel.themeManager.currentTheme }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ReadingGoalCard(goal: viewModel.readingGoal, theme: theme) {
                        showingGoalSheet = true
                    }
                    
                    // Currently Reading Section
                    VStack(alignment: .center, spacing: 12) {
                        Text("Currently Reading")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(theme.text)
                        
                        if viewModel.currentlyReadingBooks.isEmpty {
                            EmptyReadingState_Backup(theme: theme)
                        } else if viewModel.currentlyReadingBooks.count <= 2 {
                            // Static layout for 1-2 books
                            HStack {
                                Spacer()
                                HStack(spacing: 20) {
                                    ForEach(viewModel.currentlyReadingBooks) { book in
                                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                                            BookCard(book: book, theme: theme)
                                                .frame(width: 140)
                                        }
                                    }
                                }
                                Spacer()
                            }
                        } else {
                            // Scrolling layout for 3+ books
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(viewModel.currentlyReadingBooks) { book in
                                        NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                                            BookCard(book: book, theme: theme)
                                                .frame(width: 140)
                                        }
                                        .id(book.id)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(viewModel.readingGoal.year.yearString) Books")
                        .font(.system(size: 38, design: .rounded))
                        .fontWeight(.light)
                        .foregroundColor(Color(hex: "8B4513"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBook = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(theme.primary)
                            .font(.system(size: 20, weight: .light))
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingGoalSheet) {
                GoalSettingView(viewModel: viewModel)
            }
        }
    }
}

struct EmptyReadingState_Backup: View {
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Cozy reading icon
            ZStack {
                Circle()
                    .fill(theme.secondary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "books.vertical.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.primary, theme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("Your Reading Nook Awaits")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(theme.text)
                
                Text("Time to discover your next great read")
                    .font(.subheadline)
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
} 