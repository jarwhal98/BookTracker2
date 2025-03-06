import SwiftUI

struct GoalCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: ReadingGoal
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(.yellow.opacity(0.1))
                .scaleEffect(2)
                .blur(radius: 50)
            
            // Content
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
            
            // Confetti overlay
            BookConfettiView(isActive: showConfetti)
                .allowsHitTesting(false)
                .ignoresSafeArea()
        }
        .onAppear {
            // Ensure we're on the main thread and give a tiny delay for view to be ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showConfetti = true
            }
        }
    }
}
