import SwiftUI

enum BookSort {
    case title
    case author
    case dateCompleted
    
    var label: String {
        switch self {
        case .title: return "Title"
        case .author: return "Author"
        case .dateCompleted: return "Date Completed"
        }
    }
}

struct BookFilter: OptionSet {
    let rawValue: Int
    
    static let owned = BookFilter(rawValue: 1 << 0)
    static let notOwned = BookFilter(rawValue: 1 << 1)
    static let currentlyReading = BookFilter(rawValue: 1 << 2)
    static let completed = BookFilter(rawValue: 1 << 3)
    static let toRead = BookFilter(rawValue: 1 << 4)
    
    static let all: BookFilter = [.owned, .notOwned, .currentlyReading, .completed, .toRead]
    static let ownership: BookFilter = [.owned, .notOwned]
    static let readingStatus: BookFilter = [.currentlyReading, .completed, .toRead]
}

struct BookshelfView: View {
    @ObservedObject var viewModel: BookTrackerViewModel
    var theme: AppTheme { viewModel.themeManager.currentTheme }
    @State private var activeFilters: BookFilter = .all
    @State private var searchText = ""
    @State private var sortBy: BookSort = .title
    @State private var showFilterSheet = false
    @State private var showingAddBook = false
    
    var filteredBooks: [Book] {
        viewModel.books.filter { book in
            // Check ownership filters
            let ownershipMatch = activeFilters.contains(.all) ||
                (activeFilters.contains(.owned) && book.isOwned) ||
                (activeFilters.contains(.notOwned) && !book.isOwned)
            
            // Check reading status filters
            let statusMatch = activeFilters.contains(.all) ||
                (activeFilters.contains(.currentlyReading) && book.status == .currentlyReading) ||
                (activeFilters.contains(.completed) && book.status == .completed) ||
                (activeFilters.contains(.toRead) && book.status == .toRead)
            
            return ownershipMatch && statusMatch
        }
    }
    
    var filteredAndSortedBooks: [Book] {
        let searchFiltered = searchText.isEmpty ? filteredBooks : filteredBooks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText)
        }
        
        return searchFiltered.sorted { first, second in
            switch sortBy {
            case .title:
                return first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
                
            case .author:
                let firstName = first.author.split(separator: " ").last ?? ""
                let secondName = second.author.split(separator: " ").last ?? ""
                return firstName.localizedCaseInsensitiveCompare(String(secondName)) == .orderedAscending
                
            case .dateCompleted:
                // Handle books without completion dates
                guard let firstDate = first.dateCompleted else { return false }
                guard let secondDate = second.dateCompleted else { return true }
                return firstDate > secondDate // Most recent first
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Unified search and control bar
                HStack(spacing: 16) {
                    // Search Field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.secondary)
                        TextField("Search", text: $searchText)
                            .foregroundColor(theme.text)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(theme.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(theme.cardBackground)
                    .cornerRadius(8)
                    
                    // Sort Menu
                    Menu {
                        ForEach([BookSort.title, .author, .dateCompleted], id: \.label) { sort in
                            Button {
                                sortBy = sort
                            } label: {
                                if sortBy == sort {
                                    Label(sort.label, systemImage: "checkmark")
                                } else {
                                    Text(sort.label)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(theme.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, -12)
                
                // Filter chips
                filterChips
                    .padding(.top, 8)
                
                // Scrollable book list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredAndSortedBooks.enumerated()), id: \.element.id) { index, book in
                            NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                                BookRow(book: book, theme: theme, isAlternate: index % 2 == 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Bookshelf")
                        .font(.system(size: 38, design: .rounded))
                        .fontWeight(.light)
                        .foregroundColor(Color(hex: "8B4513"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddBookView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                        // We'll add the exact styling here once you share the reference code
                    }
                }
            }
        }
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Ownership filters
                FilterChip(
                    title: "Owned",
                    isSelected: activeFilters.contains(.owned),
                    theme: theme
                ) {
                    toggleFilter(.owned)
                }
                
                FilterChip(
                    title: "Not Owned",
                    isSelected: activeFilters.contains(.notOwned),
                    theme: theme
                ) {
                    toggleFilter(.notOwned)
                }
                
                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 4)
                
                // Reading status filters
                FilterChip(
                    title: "Currently Reading",
                    isSelected: activeFilters.contains(.currentlyReading),
                    theme: theme
                ) {
                    toggleFilter(.currentlyReading)
                }
                
                FilterChip(
                    title: "Completed",
                    isSelected: activeFilters.contains(.completed),
                    theme: theme
                ) {
                    toggleFilter(.completed)
                }
                
                FilterChip(
                    title: "To Read",
                    isSelected: activeFilters.contains(.toRead),
                    theme: theme
                ) {
                    toggleFilter(.toRead)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func toggleFilter(_ filter: BookFilter) {
        if activeFilters.contains(filter) {
            activeFilters.remove(filter)
            if activeFilters.isEmpty {
                activeFilters = .all
            }
        } else {
            if activeFilters == .all {
                activeFilters = []
            }
            activeFilters.insert(filter)
        }
    }
}

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var activeFilters: BookFilter
    let theme: AppTheme
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ownership") {
                    Toggle("Owned Books", isOn: binding(for: .owned))
                    Toggle("Not Owned Books", isOn: binding(for: .notOwned))
                }
                
                Section("Reading Status") {
                    Toggle("Currently Reading", isOn: binding(for: .currentlyReading))
                    Toggle("Completed", isOn: binding(for: .completed))
                    Toggle("To Read", isOn: binding(for: .toRead))
                }
                
                Section {
                    Button("Clear All Filters") {
                        activeFilters = .all
                    }
                }
            }
            .navigationTitle("Filter Books")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func binding(for filter: BookFilter) -> Binding<Bool> {
        Binding(
            get: { activeFilters.contains(filter) },
            set: { isEnabled in
                if isEnabled {
                    activeFilters.insert(filter)
                } else {
                    activeFilters.remove(filter)
                }
            }
        )
    }
}

struct BookRow: View {
    let book: Book
    let theme: AppTheme
    let isAlternate: Bool
    
    var cardBackground: Color {
        isAlternate ? Color(hex: "C5A3A3").opacity(0.25) : theme.cardBackground
    }
    
    var secondaryTextColor: Color {
        isAlternate ? .white.opacity(0.9) : theme.secondaryText
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Cover Image
            Group {
                if let url = book.coverUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            placeholderCover
                                .onAppear {
                                    debugPrint("Loading cover for '\(book.title)' from \(url)")
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 75)
                                .clipped()
                                .onAppear {
                                    debugPrint("Successfully loaded cover for '\(book.title)'")
                                }
                        case .failure(let error):
                            placeholderCover
                                .onAppear {
                                    debugPrint("Failed to load cover for '\(book.title)': \(error)")
                                }
                        @unknown default:
                            placeholderCover
                        }
                    }
                    .id(url)
                } else {
                    placeholderCover
                        .onAppear {
                            debugPrint("No cover URL for '\(book.title)'")
                        }
                }
            }
            .frame(width: 50, height: 75)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(theme.text)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
                
                HStack(spacing: 6) {
                    if let rating = book.rating {
                        QuarterStarRating(
                            rating: .constant(rating),
                            starSize: 10,
                            spacing: 1,
                            disabled: true
                        )
                    }
                    
                    Text(book.status.rawValue)
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                    
                    if book.isOwned {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 10))
                            .foregroundColor(secondaryTextColor)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .cornerRadius(10)
        .shadow(color: theme.secondary.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var placeholderCover: some View {
        Rectangle()
            .fill(theme.secondary.opacity(0.1))
            .overlay(
                Image(systemName: "book.closed")
                    .font(.system(size: 20))  // Smaller icon
                    .foregroundColor(theme.secondary.opacity(0.5))
            )
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.primary.opacity(0.2) : theme.cardBackground)
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? theme.primary : theme.secondary.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(isSelected ? theme.primary : theme.secondaryText)
        }
    }
} 