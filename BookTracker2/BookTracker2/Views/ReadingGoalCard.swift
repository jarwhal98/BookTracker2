import SwiftUI

struct ReadingGoalCard: View {
    let goal: ReadingGoal
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Main content
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reading Goal")
                                .font(.subheadline)
                                .foregroundColor(theme.secondaryText)
                            Text("\(goal.completedBooks) of \(goal.targetBooks)")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(theme.text)
                        }
                        
                        Spacer()
                        
                        // Trophy or percentage
                        if goal.percentageCompleted >= 100 {
                            Image("trophy")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 230)
                                .padding(.horizontal, 20)
                                .offset(x: -10, y: 30)
                        } else {
                            Text("\(Int(goal.percentageCompleted))%")
                                .font(.system(size: 72, design: .rounded))
                                .fontWeight(.light)
                                .foregroundColor(theme.secondary.opacity(0.25))
                                .shadow(color: theme.secondary.opacity(0.1), radius: 2, x: 2, y: 2)
                                .padding(.trailing, 20)
                                .padding(.top, 12)
                                .offset(x: -20)
                        }
                    }
                    .frame(height: 140)
                    
                    // Book progress container
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Reading Progress")
                            .font(.caption)
                            .foregroundColor(theme.secondaryText.opacity(0.7))
                            .padding(.bottom, 4)
                        
                        BookStackProgress(progress: goal.percentageCompleted / 100, theme: theme)
                            .frame(height: 67)
                        
                        // Year Progress Bar
                        VStack(alignment: .leading, spacing: 4) {
                            GeometryReader { geometry in
                                HStack(spacing: 1) {
                                    ForEach(1...12, id: \.self) { month in
                                        Rectangle()
                                            .fill(
                                                month <= Calendar.current.component(.month, from: Date()) 
                                                ? theme.primary 
                                                : theme.secondary.opacity(0.2)
                                            )
                                    }
                                }
                            }
                            .frame(height: 4)
                            
                            Text("Year Progress")
                                .font(.caption)
                                .foregroundColor(theme.secondaryText.opacity(0.7))
                        }
                        .padding(.top, 12)
                    }
                    .padding(.vertical, 8)
                    
                    // Reading Pace
                    if let currentPace = goal.currentPace {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.isAheadOfSchedule ? "Ahead of Schedule" : "Behind Schedule")
                                    .font(.subheadline)
                                    .foregroundColor(
                                        goal.isAheadOfSchedule ? 
                                        Color(hex: "2D5A27") 
                                        : Color(hex: "8B3A3A")
                                    )
                                Text(String(format: "%.1f books/year at current pace", currentPace))
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryText)
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(theme.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                .padding(.horizontal)

                // Empty overlay - removed duplicate trophy
                if goal.percentageCompleted >= 100 {
                    // Trophy removed from here
                }
            }
        }
        .buttonStyle(.plain)
    }
} 