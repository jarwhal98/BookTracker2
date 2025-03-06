import SwiftUI

struct Flower: Identifiable {
    let id = UUID()
    var yPosition: CGFloat
    var xPosition: CGFloat
    var scale: CGFloat
    var rotation: Double
    var color: Color
}

struct FlowerFallView: View {
    let theme: AppTheme
    @State private var flowers: [Flower] = []
    
    var flowerColors: [Color] {
        [
            theme.primary,
            theme.primary.opacity(0.8),
            theme.secondary,
            theme.secondary.opacity(0.8)
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(flowers) { flower in
                    FlowerPetal(color: flower.color)
                        .frame(width: 20, height: 20)
                        .scaleEffect(flower.scale)
                        .rotationEffect(.degrees(flower.rotation))
                        .offset(x: flower.xPosition, y: flower.yPosition)
                }
            }
            .onAppear {
                startFlowerFall(in: geometry.size)
            }
        }
    }
    
    private func startFlowerFall(in size: CGSize) {
        // Create new flowers periodically
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let newFlower = Flower(
                yPosition: -20,
                xPosition: CGFloat.random(in: 0...size.width),
                scale: CGFloat.random(in: 0.8...1.2),
                rotation: Double.random(in: 0...360),
                color: flowerColors.randomElement() ?? theme.primary
            )
            
            withAnimation(.linear(duration: 4.0)) {
                var mutableFlower = newFlower
                mutableFlower.yPosition = size.height + 50
                flowers.append(mutableFlower)
            }
            
            // Remove flowers that have fallen off screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.1) {
                if !flowers.isEmpty {
                    flowers.removeFirst()
                }
            }
        }
        
        // Rotate flowers as they fall
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                flowers = flowers.map { flower in
                    var newFlower = flower
                    newFlower.rotation += 2
                    return newFlower
                }
            }
        }
    }
}

struct FlowerPetal: View {
    let color: Color
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { index in
                Petal()
                    .fill(color)
                    .rotationEffect(.degrees(Double(index) * 72))
            }
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
        }
    }
}

struct Petal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: 0),
            control: CGPoint(x: width * 0.8, y: height * 0.3)
        )
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.5),
            control: CGPoint(x: width * 0.2, y: height * 0.3)
        )
        
        return path
    }
}