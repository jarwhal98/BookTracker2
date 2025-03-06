import SwiftUI

struct SetupGoalView: View {
    @ObservedObject var viewModel: BookTrackerViewModel
    @State private var targetBooks: Int = 12
    
    // Add array of possible book counts
    let bookOptions = Array(1...100)
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Welcome to BookTracker")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Let's start by setting your reading goal for \(Calendar.current.component(.year, from: Date()))")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack {
                Picker("Number of Books", selection: $targetBooks) {
                    ForEach(bookOptions, id: \.self) { number in
                        Text("\(number) books").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                
                if let daysPerBook = calculateDaysPerBook() {
                    Text("You'll need to read a book every \(Int(daysPerBook.rounded())) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                viewModel.updateReadingGoal(targetBooks: targetBooks)
            }) {
                Text("Set Goal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func calculateDaysPerBook() -> Double? {
        guard let daysLeft = Calendar.current.daysLeftInYear() else { return nil }
        return Double(daysLeft) / Double(targetBooks)
    }
} 