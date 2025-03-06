import SwiftUI

struct GoalSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookTrackerViewModel
    @State private var targetBooks: Int
    
    init(viewModel: BookTrackerViewModel) {
        self.viewModel = viewModel
        _targetBooks = State(initialValue: viewModel.readingGoal.targetBooks)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Stepper("Books to read: \(targetBooks)", value: $targetBooks, in: 1...1000)
                } footer: {
                    Text("You can always adjust this goal later.")
                }
                
                if let daysPerBook = viewModel.readingGoal.daysPerBookRequired {
                    Section {
                        Text("To reach this goal, you'll need to read a book every \(Int(daysPerBook.rounded())) days")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Reading Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateReadingGoal(targetBooks: targetBooks)
                        dismiss()
                    }
                }
            }
        }
    }
} 