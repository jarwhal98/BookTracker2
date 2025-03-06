import SwiftUI

struct StarRatingView: View {
    let maxRating: Int = 5
    let starSize: CGFloat
    @Binding var rating: Double
    let theme: AppTheme
    
    // Calculate the filled portion of each star (0 to 1)
    func fillAmount(for position: Int) -> Double {
        let starPosition = Double(position)
        let difference = rating - starPosition
        
        if difference >= 1 { return 1 }      // Full star
        if difference <= 0 { return 0 }      // Empty star
        
        // Round to nearest quarter
        return (difference * 4).rounded() / 4
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxRating, id: \.self) { position in
                GeometryReader { geometry in
                    ZStack {
                        // Empty star
                        Image(systemName: "star")
                            .foregroundColor(theme.secondary.opacity(0.3))
                        
                        // Filled star with mask
                        Image(systemName: "star.fill")
                            .foregroundColor(theme.primary)
                            .mask(
                                Rectangle()
                                    .size(
                                        width: geometry.size.width * fillAmount(for: position),
                                        height: geometry.size.height
                                    )
                            )
                    }
                }
                .frame(width: starSize, height: starSize)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let width = starSize + 4 // Include spacing
                            _ = width * CGFloat(maxRating)  // Changed totalWidth to _
                            let xPos = value.location.x + width * CGFloat(position)
                            
                            // Convert to rating (0 to 5)
                            var newRating = Double(xPos) / Double(width)
                            
                            // Round to nearest quarter
                            newRating = (newRating * 4).rounded() / 4
                            
                            // Clamp between 0 and 5
                            rating = max(0, min(Double(maxRating), newRating))
                        }
                )
            }
        }
    }
} 