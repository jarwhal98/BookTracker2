import SwiftUI

struct YearEndSummaryView: View {
    let summary: YearEndSummary
    let theme: AppTheme
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(String(format: "%d Reading Journey", summary.year))
                        .font(.system(size: 32, design: .serif))
                        .fontWeight(.light)
                    
                    if summary.goalAchieved {
                        Text("Goal Achieved! 🎉")
                            .foregroundColor(theme.primary)
                            .opacity(showContent ? 1 : 0)
                            .scaleEffect(showContent ? 1 : 0.8)
                    }
                }
                .padding(.top)
                
                // Stats Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        title: "Books Read",
                        value: "\(summary.totalBooksRead)",
                        icon: "books.vertical.fill",
                        theme: theme
                    )
                    
                    StatCard(
                        title: "Average Rating",
                        value: String(format: "%.1f ⭐️", summary.averageRating),
                        icon: "star.fill",
                        theme: theme
                    )
                    
                    StatCard(
                        title: "Reading Streak",
                        value: "\(summary.longestReadingStreak) days",
                        icon: "flame.fill",
                        theme: theme
                    )
                    
                    if let (author, count) = summary.mostReadAuthor {
                        StatCard(
                            title: "Favorite Author",
                            value: "\(author) (\(count))",
                            icon: "person.fill",
                            theme: theme
                        )
                    }
                }
                .padding(.horizontal)
                
                // Top Genres
                VStack(alignment: .leading, spacing: 16) {
                    Text("Top Genres")
                        .font(.headline)
                    
                    ForEach(Array(summary.topGenres.enumerated()), id: \.element.genre) { index, genre in
                        GenreBar(
                            genre: genre.genre,
                            count: genre.count,
                            total: summary.totalBooksRead,
                            index: index,
                            theme: theme,
                            showContent: showContent
                        )
                    }
                }
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Best Book
                if let bestBook = summary.bestRatedBook {
                    VStack(spacing: 12) {
                        Text("Highest Rated Book")
                            .font(.headline)
                        
                        BookHighlight(book: bestBook, theme: theme)
                    }
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Most Productive Month
                if let month = summary.mostProductiveMonth {
                    VStack(spacing: 8) {
                        Text("Most Productive Month")
                            .font(.headline)
                        Text("\(month.month) (\(month.count) books)")
                            .font(.title2)
                            .foregroundColor(theme.primary)
                    }
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
        }
        .background(theme.background)
        .onAppear {
            withAnimation(.spring(duration: 0.7)) {
                showContent = true
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let theme: AppTheme
    @State private var show = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(theme.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(theme.secondaryText)
            
            Text(value)
                .font(.headline)
                .foregroundColor(theme.text)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
        .scaleEffect(show ? 1 : 0.8)
        .opacity(show ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                show = true
            }
        }
    }
}

struct GenreBar: View {
    let genre: String
    let count: Int
    let total: Int
    let index: Int
    let theme: AppTheme
    let showContent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(genre)
                .font(.subheadline)
                .foregroundColor(theme.text)
            
            GeometryReader { geometry in
                Rectangle()
                    .fill(theme.primary.opacity(0.2))
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(theme.primary)
                            .frame(width: showContent ? geometry.size.width * CGFloat(count) / CGFloat(total) : 0)
                    }
                    .cornerRadius(4)
            }
            .frame(height: 8)
            
            Text("\(count) books")
                .font(.caption)
                .foregroundColor(theme.secondaryText)
        }
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
            .delay(Double(index) * 0.1),
            value: showContent
        )
    }
}

struct BookHighlight: View {
    let book: Book
    let theme: AppTheme
    @State private var show = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Cover Image
            AsyncImage(url: book.coverUrl) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(theme.secondary.opacity(0.1))
                        .overlay {
                            Image(systemName: "book.closed")
                                .foregroundColor(theme.secondary)
                        }
                }
            }
            .frame(width: 60, height: 90)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(theme.secondaryText)
                if let rating = book.rating {
                    Text("Rating: \(String(format: "%.1f", rating)) ⭐️")
                        .font(.caption)
                        .foregroundColor(theme.primary)
                }
            }
        }
        .opacity(show ? 1 : 0)
        .offset(y: show ? 0 : 20)
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.8)
                .delay(0.4)
            ) {
                show = true
            }
        }
    }
} 