import SwiftUI

struct QuarterStarRating: View {
    @Binding var rating: Double
    let maxRating: Int = 5
    let starSize: CGFloat
    let spacing: CGFloat
    let onTap: ((Double) -> Void)?
    let disabled: Bool
    
    init(
        rating: Binding<Double>,
        starSize: CGFloat = 20,
        spacing: CGFloat = 4,
        disabled: Bool = false,
        onTap: ((Double) -> Void)? = nil
    ) {
        self._rating = rating
        self.starSize = starSize
        self.spacing = spacing
        self.disabled = disabled
        self.onTap = onTap
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                starImage(for: index)
                    .foregroundColor(.yellow)
                    .frame(width: starSize, height: starSize)
                    .contentShape(Rectangle())
                    .gesture(
                        disabled ? nil : DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let starWidth = starSize
                                let relativeX = value.location.x
                                let quarterStarWidth = starWidth / 4
                                
                                var newRating = Double(index - 1)
                                
                                if relativeX <= quarterStarWidth {
                                    newRating += 0.25
                                } else if relativeX <= quarterStarWidth * 2 {
                                    newRating += 0.5
                                } else if relativeX <= quarterStarWidth * 3 {
                                    newRating += 0.75
                                } else {
                                    newRating += 1.0
                                }
                                
                                rating = newRating
                                onTap?(newRating)
                            }
                    )
            }
        }
    }
    
    private func starImage(for index: Int) -> some View {
        let fillAmount = rating - Double(index - 1)
        
        return Image(systemName: starImageName(fillAmount: fillAmount))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    private func starImageName(fillAmount: Double) -> String {
        if fillAmount >= 1.0 {
            return "star.fill"
        } else if fillAmount >= 0.75 {
            return "star.leadinghalf.filled"  // Using half for now as SF Symbols doesn't have quarter stars
        } else if fillAmount >= 0.5 {
            return "star.leadinghalf.filled"
        } else if fillAmount >= 0.25 {
            return "star.leadinghalf.filled"  // Using half for now
        } else {
            return "star"
        }
    }
} 