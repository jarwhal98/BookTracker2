//
//  EditBookView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct EditBookView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookTrackerViewModel
    let book: Book
    
    @State private var title: String
    @State private var author: String
    @State private var isbn: String
    @State private var selectedGenres: Set<String>
    @State private var notes: String
    @State private var rating: Double
    @State private var showingGenreSelector = false
    @State private var selectedStatus: ReadingStatus
    
    init(viewModel: BookTrackerViewModel, book: Book) {
        self.viewModel = viewModel
        self.book = book
        _title = State(initialValue: book.title)
        _author = State(initialValue: book.author)
        _isbn = State(initialValue: book.isbn)
        _selectedGenres = State(initialValue: book.genres)
        _notes = State(initialValue: book.notes ?? "")
        _rating = State(initialValue: book.rating ?? 0)
        _selectedStatus = State(initialValue: book.status)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Book Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN", text: $isbn)
                }
                
                Section("Status") {
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(ReadingStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Genres") {
                    ForEach(Array(selectedGenres), id: \.self) { genre in
                        Text(genre)
                    }
                    Button("Edit Genres") {
                        showingGenreSelector = true
                    }
                }
                
                if selectedStatus == .completed {
                    Section("Rating") {
                        QuarterStarRating(
                            rating: $rating,
                            starSize: 30,
                            spacing: 8,
                            disabled: false
                        )
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
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
    
    private func saveChanges() {
        var updatedBook = book
        updatedBook.title = title
        updatedBook.author = author
        updatedBook.isbn = isbn
        updatedBook.genres = selectedGenres
        updatedBook.notes = notes.isEmpty ? nil : notes
        updatedBook.rating = rating > 0 ? rating : nil
        updatedBook.status = selectedStatus
        
        if selectedStatus == .completed && book.status != .completed {
            updatedBook.dateCompleted = Date()
        } else if selectedStatus != .completed {
            updatedBook.dateCompleted = nil
            updatedBook.rating = nil
        }
        
        viewModel.updateBookStatus(updatedBook, to: selectedStatus)
        dismiss()
    }
} 