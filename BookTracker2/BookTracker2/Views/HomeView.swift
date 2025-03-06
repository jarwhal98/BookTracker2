//
//  HomeView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: BookTrackerViewModel
    @State private var showingAddBook = false
    @State private var showingGoalSheet = false
    
    var theme: AppTheme { viewModel.themeManager.currentTheme }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ReadingGoalCard(
                        goal: viewModel.readingGoal,
                        theme: theme,
                        action: { showingGoalSheet = true }
                    )
                    .padding(.top, 20)
                    
                    // Currently Reading Section
                    VStack(alignment: .center, spacing: 12) {
                        Text("Currently Reading")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(theme.text)
                        
                        if viewModel.currentlyReadingBooks.isEmpty {
                            EmptyReadingState(theme: theme)
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
            .navigationBarTitleDisplayMode(.inline)
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

struct EmptyReadingState: View {
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                if let image = UIImage(named: "reading-chair") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(0.6)
                }
                
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Your")
                            Text("Reading")
                            Text("Nook")
                            Text("Awaits")
                        }
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(theme.text)
                        .shadow(radius: 2)
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text("Time to discover your next great read")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 2)
                        .padding(.bottom, 30)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct DecorativeElement: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            // Main vine
            var path = Path()
            path.move(to: CGPoint(x: size.width/2, y: 0))
            
            // Gentle curve
            for i in 0...20 {
                let y = size.height * Double(i) / 20
                let x = size.width/2 + sin(Double(i) * .pi / 4) * (size.width/6)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            context.stroke(path, with: .color(color), lineWidth: 1)
            
            // Simple flowers
            for i in 0...5 {
                let y = size.height * Double(i) / 5
                let x = size.width/2 + sin(Double(i) * .pi / 4) * (size.width/6)
                
                // Flower center
                let centerDot = Path(ellipseIn: CGRect(x: x-1, y: y-1, width: 2, height: 2))
                context.fill(centerDot, with: .color(color.opacity(0.5)))
                
                // Petals
                for j in 0...3 {
                    var petalPath = Path()
                    let angle = Double(j) * .pi / 2
                    petalPath.move(to: CGPoint(x: x + cos(angle) * 3, y: y + sin(angle) * 3))
                    petalPath.addQuadCurve(
                        to: CGPoint(x: x + cos(angle + .pi/4) * 3, y: y + sin(angle + .pi/4) * 3),
                        control: CGPoint(x: x + cos(angle + .pi/8) * 6, y: y + sin(angle + .pi/8) * 6)
                    )
                    context.stroke(petalPath, with: .color(color.opacity(0.4)), lineWidth: 0.5)
                }
            }
        }
    }
} 
