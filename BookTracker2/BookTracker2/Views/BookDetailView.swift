//
//  BookDetailView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct BookDetailView: View {
    @ObservedObject var viewModel: BookTrackerViewModel
    let book: Book
    @State private var showingEditSheet = false
    @State private var showingCompletionSheet = false
    @State private var rating: Double = 0
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Cover Image
                bookCoverView
                
                // Book Details
                bookDetailsView
                
                // Mark as Read Button
                if book.status == .currentlyReading {
                    markAsReadButton
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .alert("Delete Book", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteBook(book)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(book.title)'? This cannot be undone.")
        }
        .sheet(isPresented: $showingEditSheet) {
            EditBookView(viewModel: viewModel, book: book)
        }
        .sheet(isPresented: $showingCompletionSheet) {
            BookCompletionView(viewModel: viewModel, book: book)
        }
        .onAppear {
            rating = book.rating ?? 0
        }
    }
    
    // MARK: - View Components
    
    private var bookCoverView: some View {
        Group {
            if let url = book.coverUrl {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(height: 300)
                .cornerRadius(12)
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    private var bookDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and Author
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.title)
                    .fontWeight(.bold)
                Text(book.author)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            // Status
            statusView
            
            // Rating
            if book.status == .completed {
                ratingView
            }
            
            // Genres
            genresView
            
            // ISBN
            isbnView
            
            // Notes
            if let notes = book.notes {
                notesView(notes)
            }
        }
        .padding()
    }
    
    private var statusView: some View {
        HStack {
            Text("Status:")
                .fontWeight(.medium)
            Menu {
                ForEach(ReadingStatus.allCases, id: \.self) { status in
                    Button {
                        let updatedBook = book
                        viewModel.updateBookStatus(updatedBook, to: status)
                    } label: {
                        if status == book.status {
                            Label(status.displayName, systemImage: "checkmark")
                        } else {
                            Text(status.displayName)
                        }
                    }
                }
            } label: {
                Text(book.status.displayName)
                    .foregroundColor(.blue)
            }
            
            if book.status == .completed, let completionDate = book.dateCompleted {
                Spacer()
                Text("Completed:")
                    .fontWeight(.medium)
                Text(completionDate.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var ratingView: some View {
        QuarterStarRating(
            rating: $rating,
            starSize: 30,
            spacing: 8,
            disabled: false,
            onTap: { newRating in
                var updatedBook = book
                updatedBook.rating = newRating
                viewModel.updateBook(updatedBook)
            }
        )
    }
    
    private var genresView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(book.genres), id: \.self) { genre in
                    Text(genre)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                }
            }
        }
    }
    
    private var isbnView: some View {
        HStack {
            Text("ISBN:")
                .fontWeight(.medium)
            Text(book.isbn)
        }
    }
    
    private func notesView(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            Text(notes)
                .foregroundColor(.secondary)
        }
    }
    
    private var markAsReadButton: some View {
        Button(action: {
            showingCompletionSheet = true
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Mark as Completed")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
} 
