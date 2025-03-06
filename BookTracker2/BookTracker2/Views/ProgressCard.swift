import SwiftUI

struct ProgressCard: View {
    let goal: YearlyGoal?
    let theme: AppTheme
    let action: () -> Void
    
    var progress: Double {
        guard let goal = goal, goal.targetBooks > 0 else { return 0 }
        return Double(goal.completedBooks) / Double(goal.targetBooks)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reading Goal")
                            .font(.headline)
                            .foregroundColor(theme.text)
                        
                        if let goal = goal {
                            Text("\(goal.completedBooks) of \(goal.targetBooks) books")
                                .font(.subheadline)
                                .foregroundColor(theme.secondaryText)
                        } else {
                            Text("No goal set")
                                .font(.subheadline)
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    CircularProgressView(progress: progress)
                        .frame(width: 60, height: 60)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(theme.secondary.opacity(0.2))
                        
                        Rectangle()
                            .fill(theme.primary)
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .frame(height: 8)
                .cornerRadius(4)
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
} 