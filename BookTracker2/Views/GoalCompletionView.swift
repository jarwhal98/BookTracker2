import SwiftUI

struct GoalCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: ReadingGoal
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.yellow.gradient)
                .symbolEffect(.bounce)
            
            VStack(spacing: 16) {
                Text("Congratulations! 🎉")
                    .font(.title)
                    .bold()
                
                Text("You've reached your reading goal of \(goal.targetBooks) books in \(goal.year)!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                Text("Keep reading and set a new goal!")
                    .foregroundColor(.secondary)
            }
            
            Button("Continue Reading") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top)
        }
        .padding()
        .background {
            Circle()
                .fill(.yellow.opacity(0.1))
                .scaleEffect(2)
                .blur(radius: 50)
        }
    }
} 