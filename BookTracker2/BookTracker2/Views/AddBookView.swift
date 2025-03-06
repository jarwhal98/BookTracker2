//
//  AddBookView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI
import AVFoundation

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookTrackerViewModel
    @StateObject private var scannerViewModel = ISBNScannerViewModel()
    
    var theme: AppTheme { viewModel.themeManager.currentTheme }
    
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedGenres: Set<String> = []
    @State private var notes = ""
    @State private var showingScanner = false
    @State private var showingGenreSelector = false
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var searchResults: [SearchResult] = []
    @State private var isShowingResults = false
    @State private var isLoading = false
    @State private var showingGenreAlert = false
    @State private var coverUrl: URL?
    @State private var selectedStatus: ReadingStatus = .currentlyReading
    @State private var completionDate = Date()
    @State private var ownership: Ownership? = nil
    @State private var rating: Double = 0.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Section
                    VStack(spacing: 12) {
                        // Search Field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(theme.secondary)
                            TextField("Search by title or author", text: $searchQuery)
                                .foregroundColor(theme.text)
                                .onChange(of: searchQuery) { oldValue, newValue in
                                    if !newValue.isEmpty && newValue.count > 2 {
                                        isShowingResults = true
                                        // Add debouncing
                                        Task {
                                            try? await Task.sleep(for: .milliseconds(300))
                                            // Only search if the query hasn't changed during the delay
                                            if searchQuery == newValue {
                                                searchBooks(query: newValue)
                                            }
                                        }
                                    } else {
                                        isShowingResults = false
                                        searchResults = []
                                    }
                                }
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else if !searchQuery.isEmpty {
                                Button(action: { searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(theme.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(theme.cardBackground)
                        .cornerRadius(10)
                        
                        // ISBN Search Link
                        Button(action: { showingScanner = true }) {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                Text("Search by ISBN")
                            }
                            .foregroundColor(theme.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Search Results
                    if isShowingResults && !searchResults.isEmpty {
                        Divider()
                            .padding(.horizontal)
                        searchResultsView
                    }
                    
                    // Book Details Form
                    VStack(spacing: 16) {
                        // Required Fields Section
                        GroupBox("Required Details") {
                            VStack(spacing: 12) {
                                formField(title: "Title", text: $title)
                                formField(title: "Author", text: $author)
                                
                                // Genre Selection
                                Button(action: { showingGenreSelector = true }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Genres")
                                                .font(.subheadline)
                                                .foregroundColor(theme.secondaryText)
                                            if selectedGenres.isEmpty {
                                                Text("Select genres...")
                                                    .foregroundColor(theme.secondary)
                                            } else {
                                                Text(selectedGenres.joined(separator: ", "))
                                                    .foregroundColor(theme.text)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(theme.secondary)
                                    }
                                }
                                
                                // Ownership Picker
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Do you own this book?")
                                        .font(.subheadline)
                                        .foregroundColor(theme.secondaryText)
                                    Picker("Ownership", selection: $ownership) {
                                        Text("Select...").tag(Optional<Ownership>.none)
                                        ForEach(Ownership.allCases, id: \.self) { option in
                                            Text(option.rawValue).tag(Optional(option))
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                            .padding()
                        }
                        
                        // Optional Details Section
                        GroupBox("Additional Details") {
                            VStack(spacing: 12) {
                                // Reading Status
                                Picker("Status", selection: $selectedStatus) {
                                    ForEach([ReadingStatus.toRead, .currentlyReading, .completed], id: \.self) { status in
                                        Text(status.displayName).tag(status)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                if selectedStatus == .completed {
                                    VStack(spacing: 8) {
                                        DatePicker(
                                            "Completion Date",
                                            selection: $completionDate,
                                            displayedComponents: [.date]
                                        )
                                        
                                        // Add Rating
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Rating")
                                                .font(.subheadline)
                                                .foregroundColor(theme.secondaryText)
                                            QuarterStarRating(
                                                rating: $rating,
                                                starSize: 24,
                                                spacing: 4,
                                                disabled: false
                                            )
                                        }
                                    }
                                }
                                
                                // Notes
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notes")
                                        .font(.subheadline)
                                        .foregroundColor(theme.secondaryText)
                                    TextEditor(text: $notes)
                                        .frame(height: 100)
                                        .padding(8)
                                        .background(theme.cardBackground)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let ownershipValue = ownership else {
                            // Show ownership required alert
                            return
                        }
                        saveBook(isOwned: ownershipValue == .yes)
                    }
                    .disabled(ownership == nil || title.isEmpty || author.isEmpty || selectedGenres.isEmpty)
                }
            }
            .alert("Genre Required", isPresented: $showingGenreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please select at least one genre before saving.")
            }
            .sheet(isPresented: $showingScanner) {
                ISBNScannerView(viewModel: scannerViewModel) { scannedISBN in
                    self.isbn = scannedISBN
                    isShowingResults = true  // Set this to true to show results
                    searchBooks(query: scannedISBN)  // Search for book details using the ISBN
                }
            }
            .sheet(isPresented: $showingGenreSelector) {
                GenreSelectorView(
                    viewModel: viewModel,
                    selectedGenres: $selectedGenres
                )
            }
        }
    }
    
    private func formField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
            TextField(title, text: text)
                .textFieldStyle(.plain)
                .padding(8)
                .background(theme.cardBackground)
                .cornerRadius(8)
        }
    }
    
    private func saveBook(isOwned: Bool) {
        print("Saving book with cover URL: \(String(describing: coverUrl))")
        let book = Book(
            title: title,
            author: author,
            isbn: isbn,
            coverUrl: coverUrl,
            genres: selectedGenres,
            notes: notes.isEmpty ? nil : notes,
            status: selectedStatus,
            dateCompleted: selectedStatus == .completed ? completionDate : nil,
            readCount: 0,
            isOwned: isOwned
        )
        viewModel.addBook(book)
        dismiss()
    }
    
    private func searchBooks(query: String) {
        Task {
            isLoading = true
            do {
                let results = try await BookSearchService.shared.searchBooks(query: query)
                await MainActor.run {
                    if query == isbn && !results.isEmpty {
                        // If this is an ISBN search, automatically select the first matching result
                        selectBook(results[0])
                    } else {
                        // For regular title/author searches, show the results list
                        searchResults = results
                        isShowingResults = true
                    }
                    isLoading = false
                }
            } catch {
                print("Search error: \(error)")
                await MainActor.run {
                    searchResults = []
                    isLoading = false
                }
            }
        }
    }
    
    private func selectBook(_ result: SearchResult) {
        print("Selected book cover URL: \(String(describing: result.coverUrl))")
        title = result.title
        author = result.author
        if let isbn = result.isbn {
            self.isbn = isbn
        }
        self.coverUrl = result.coverUrl
        isShowingResults = false
        searchQuery = ""
        searchResults = []  // Clear the search results
    }
    
    private var searchResultsView: some View {
        VStack(spacing: 12) {
            ForEach(searchResults) { result in
                Button(action: { selectBook(result) }) {
                    HStack(spacing: 12) {
                        // Cover Image
                        Group {
                            if let url = result.coverUrl {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        placeholderCover
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        placeholderCover
                                    @unknown default:
                                        placeholderCover
                                    }
                                }
                            } else {
                                placeholderCover
                            }
                        }
                        .frame(width: 40, height: 60)
                        .cornerRadius(4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.headline)
                                .foregroundColor(theme.text)
                            Text(result.author)
                                .font(.subheadline)
                                .foregroundColor(theme.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(theme.secondary)
                    }
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var placeholderCover: some View {
        Rectangle()
            .fill(theme.secondary.opacity(0.1))
            .overlay(
                Image(systemName: "book.closed")
                    .foregroundColor(theme.secondary)
            )
    }
}

enum Ownership: String, CaseIterable {
    case yes = "Yes"
    case no = "No"
} 