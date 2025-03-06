import SwiftUI

struct BookStackProgress: View {
    let progress: Double
    let theme: AppTheme
    
    private let totalBooks = 18
    private var filledBooks: Int {
        min(Int(progress * Double(totalBooks)), totalBooks)
    }
    
    // Updated color palette for books
    private var bookColors: [Color] {
        [
            Color(hex: "C5A3A3"),  // Darker dusty rose
            Color(hex: "D4B8B8"),  // Darker light pink
            Color(hex: "CCAFAF"),  // Darker soft pink
            Color(hex: "B0ADAD"),  // Darker gray
            Color(hex: "A5B9BA")   // Darker blue-gray
        ]
    }
    
    // Get a color that's different from the previous one
    private func getColor(at index: Int) -> Color {
        let previousIndex = (index - 1 + bookColors.count) % bookColors.count
        let currentOptions = bookColors.filter { $0 != bookColors[previousIndex] }
        return currentOptions[index % currentOptions.count]
    }
    
    // Calculate exact fill amount for each book
    private func getFillAmount(for index: Int) -> Double {
        let booksNeeded = progress * Double(totalBooks)
        if Double(index) + 1 <= booksNeeded {
            return 1.0  // Completely filled
        } else if Double(index) < booksNeeded {
            return booksNeeded - Double(index)  // Partially filled
        }
        return 0  // Empty
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack(spacing: 1) {
                    ForEach(0..<totalBooks, id: \.self) { index in
                        VStack {
                            Spacer()
                            BookSpine(
                                fillAmount: getFillAmount(for: index),
                                theme: theme,
                                color: getColor(at: index),
                                height: Double.random(in: 35...65)
                            )
                        }
                    }
                }
                .frame(maxWidth: geometry.size.width)
            }
        }
    }
}

struct BookSpine: View {
    let fillAmount: Double
    let theme: AppTheme
    let color: Color
    let height: Double
    
    // Random decoration style for each book
    private var decorationType: Int {
        Int.random(in: 0...4)
    }
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        theme.secondaryText.opacity(0.1),
                        theme.secondaryText.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color,
                                    color.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .mask(
                            Rectangle()
                                .frame(width: geometry.size.width * fillAmount)
                                .frame(maxWidth: geometry.size.width, alignment: .leading)
                        )
                }
            )
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay(
                Group {
                    if fillAmount > 0 {
                        switch decorationType {
                        case 0:  // Classic lines
                            VStack(spacing: 6) {
                                Rectangle()
                                    .fill(theme.cardBackground.opacity(0.3))
                                    .frame(width: 8, height: 1)
                                Rectangle()
                                    .fill(theme.cardBackground.opacity(0.3))
                                    .frame(width: 8, height: 1)
                            }
                            .padding(.vertical, 8)
                            
                        case 1:  // Dots and line
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(theme.cardBackground.opacity(0.4))
                                    .frame(width: 2, height: 2)
                                Rectangle()
                                    .fill(theme.cardBackground.opacity(0.3))
                                    .frame(width: 6, height: 1)
                                Circle()
                                    .fill(theme.cardBackground.opacity(0.4))
                                    .frame(width: 2, height: 2)
                            }
                            .padding(.vertical, 6)
                            
                        case 2:  // Ornate pattern
                            VStack(spacing: 3) {
                                Rectangle()
                                    .fill(theme.cardBackground.opacity(0.3))
                                    .frame(width: 10, height: 1)
                                HStack(spacing: 2) {
                                    Circle()
                                        .fill(theme.cardBackground.opacity(0.4))
                                        .frame(width: 2, height: 2)
                                    Circle()
                                        .fill(theme.cardBackground.opacity(0.4))
                                        .frame(width: 2, height: 2)
                                }
                                Rectangle()
                                    .fill(theme.cardBackground.opacity(0.3))
                                    .frame(width: 10, height: 1)
                            }
                            .padding(.vertical, 5)
                            
                        case 3:  // Simple dot
                            Circle()
                                .fill(theme.cardBackground.opacity(0.4))
                                .frame(width: 3, height: 3)
                                .padding(.vertical, 8)
                            
                        default:  // Minimal lines
                            Rectangle()
                                .fill(theme.cardBackground.opacity(0.3))
                                .frame(width: 8, height: 1)
                                .padding(.vertical, 10)
                        }
                    }
                }
            )
    }
} 