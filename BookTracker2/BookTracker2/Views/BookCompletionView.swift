import SwiftUI

struct BookCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookTrackerViewModel
    let book: Book
    
    @State private var rating: Double = 0
    @State private var notes: String = ""
    @State private var completionDate = Date()
    @State private var showCelebration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section("When did you finish this book?") {
                        DatePicker(
                            "Completion Date",
                            selection: $completionDate,
                            displayedComponents: [.date]
                        )
                    }
                    
                    Section("Rating (Optional)") {
                        QuarterStarRating(
                            rating: $rating,
                            starSize: 30,
                            spacing: 8,
                            disabled: false
                        )
                    }
                    
                    Section("Notes (Optional)") {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                    }
                }
                
                CelebrationOverlay(isVisible: showCelebration)
            }
            .navigationTitle("Complete Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        markAsRead()
                    }
                }
            }
        }
    }
    
    private func markAsRead() {
        var updatedBook = book
        updatedBook.rating = rating > 0 ? rating : nil
        updatedBook.notes = notes.isEmpty ? nil : notes
        updatedBook.status = .completed
        updatedBook.dateCompleted = completionDate
        
        // Check if this book will complete the goal
        let currentCompleted = viewModel.readingGoal.completedBooks
        let targetBooks = viewModel.readingGoal.targetBooks
        
        viewModel.updateBookStatus(updatedBook, to: .completed)
        
        // If this book completes the goal, show celebration
        if currentCompleted + 1 == targetBooks {
            withAnimation {
                showCelebration = true
            }
            // Dismiss after celebration (increased to 6 seconds to match longer animation)
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                dismiss()
            }
        } else {
            dismiss()
        }
    }
} 