//
//  GenreSelectorView.swift
//  BookTracker2
//
//  Created by Jonathan Werle on 2/23/25.
//


import SwiftUI

struct GenreSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookTrackerViewModel
    @Binding var selectedGenres: Set<String>
    @State private var newGenre = ""
    @State private var showingAddGenreField = false
    @State private var genreToDelete: String? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if showingAddGenreField {
                        HStack {
                            TextField("New Genre", text: $newGenre)
                            Button("Add") {
                                let trimmedGenre = newGenre.trimmingCharacters(in: .whitespaces)
                                if !trimmedGenre.isEmpty {
                                    viewModel.addNewGenre(trimmedGenre)
                                    selectedGenres.insert(trimmedGenre)
                                    newGenre = ""
                                    showingAddGenreField = false
                                }
                            }
                            .disabled(newGenre.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    } else {
                        Button("Add New Genre") {
                            showingAddGenreField = true
                        }
                    }
                }
                
                Section {
                    ForEach(Array(viewModel.availableGenres).sorted(), id: \.self) { genre in
                        HStack {
                            Text(genre)
                            Spacer()
                            if selectedGenres.contains(genre) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedGenres.contains(genre) {
                                selectedGenres.remove(genre)
                            } else {
                                selectedGenres.insert(genre)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if viewModel.isCustomGenre(genre) {
                                Button(role: .destructive) {
                                    genreToDelete = genre
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Genres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Genre?", isPresented: $showingDeleteAlert, presenting: genreToDelete) { genre in
                Button("Cancel", role: .cancel) {
                    genreToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let genreToDelete = genreToDelete {
                        selectedGenres.remove(genreToDelete)
                        viewModel.deleteGenre(genreToDelete)
                    }
                    genreToDelete = nil
                }
            } message: { genre in
                let count = viewModel.isGenreInUse(genre)
                if count > 0 {
                    Text("This genre is used by \(count) book\(count == 1 ? "" : "s"). The genre will be removed from your available genres but will remain on existing books.")
                } else {
                    Text("Are you sure you want to delete this genre?")
                }
            }
        }
    }
} 