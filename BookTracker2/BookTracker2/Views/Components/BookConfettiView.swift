import SwiftUI

struct BookConfettiView: View {
    let isActive: Bool
    
    let columns = Array(repeating: GridItem(.flexible()), count: 10)
    @State private var animateItems = false
    
    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0..<40) { index in
                    let isBook = index % 2 == 0
                    
                    Group {
                        if isBook {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.brown)
                                .frame(width: 20, height: 15)
                        } else {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.white)
                                .frame(width: 12, height: 15)
                        }
                    }
                    .offset(y: animateItems ? randomOffset() : 0)
                    .rotationEffect(.degrees(animateItems ? Double.random(in: -360...360) : 0))
                    .opacity(animateItems ? 0 : 1)
                    .animation(
                        .spring(
                            response: 0.6,
                            dampingFraction: 0.7
                        )
                        .delay(Double.random(in: 0...0.3)),
                        value: animateItems
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startAnimation()
                }
            }
        }
    }
    
    private func randomOffset() -> CGFloat {
        let randomY = CGFloat.random(in: 300...600)
        return randomY
    }
    
    private func startAnimation() {
        animateItems = false
        
        // Reset and start animation
        DispatchQueue.main.async {
            animateItems = true
        }
    }
}