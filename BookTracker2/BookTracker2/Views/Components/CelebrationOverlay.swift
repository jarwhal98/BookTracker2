import SwiftUI

struct CelebrationOverlay: View {
    let isVisible: Bool
    
    @State private var particles: [ParticleData] = []
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    
    // Array of book colors matching the progress table
    let bookColors: [Color] = [
        Color(hex: "C5A3A3"),  // Darker dusty rose
        Color(hex: "D4B8B8"),  // Darker light pink
        Color(hex: "CCAFAF"),  // Darker soft pink
        Color(hex: "B0ADAD"),  // Darker gray
        Color(hex: "A5B9BA")   // Darker blue-gray
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark semi-transparent background
                Color.black.opacity(0.7)
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeIn(duration: 0.3), value: isVisible)
                
                // Congratulatory text
                VStack(spacing: 20) {
                    Text("Congratulations!")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 4)
                    Text("You've hit your reading target! 🎉")
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)
                .zIndex(1)  // Ensure text stays on top
                
                // Falling particles
                ForEach(particles) { particle in
                    Group {
                        if particle.isBook {
                            // Book shape
                            BookShape()
                                .fill(particle.color)
                                .frame(width: particle.size.width, height: particle.size.height)
                                .shadow(radius: 2)
                        } else {
                            // Page shape
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: particle.size.width * 0.8, height: particle.size.height)
                                .shadow(radius: 1)
                        }
                    }
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.position.x, y: particle.position.y)
                    .opacity(particle.opacity)
                }
            }
            .onChange(of: isVisible) { _, newValue in
                if newValue {
                    startCelebration(in: geometry.size)
                } else {
                    particles = []
                    titleScale = 0.5
                    titleOpacity = 0
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func startCelebration(in size: CGSize) {
        // Reset state
        particles = []
        
        // Animate title
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            titleScale = 1.0
            titleOpacity = 1
        }
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Initial explosion
        createExplosion(at: center, in: size, particleCount: 40)
        
        // Secondary explosions
        for i in 1...8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                createExplosion(at: center, in: size, particleCount: 15)
            }
        }
    }
    
    private func createExplosion(at center: CGPoint, in size: CGSize, particleCount: Int) {
        for _ in 0..<particleCount {
            let angle = Double.random(in: 0...(2 * .pi))
            let initialVelocity = Double.random(in: 300...600)
            let gravity: Double = 800  // Pixels per second squared
            
            let particle = ParticleData(
                id: UUID(),
                position: center,
                rotation: Double.random(in: 0...360),
                isBook: Bool.random(),
                opacity: 1,
                color: bookColors.randomElement() ?? .brown,
                size: CGSize(
                    width: CGFloat.random(in: 20...35),
                    height: CGFloat.random(in: 30...45)
                )
            )
            particles.append(particle)
            
            // Initial explosion animation
            let initialDuration = 0.8
            let initialX = center.x + cos(angle) * initialVelocity
            let initialY = center.y + sin(angle) * initialVelocity
            
            withAnimation(
                .easeOut(duration: initialDuration)
                .delay(Double.random(in: 0...0.2))
            ) {
                let index = particles.count - 1
                particles[index].position = CGPoint(x: initialX, y: initialY)
                particles[index].rotation += Double.random(in: 360...720)
            }
            
            // Gravity animation
            let finalDuration = 1.5
            let finalX = initialX + cos(angle) * initialVelocity * 0.5  // Horizontal drift
            let finalY = initialY + gravity * finalDuration  // Gravity effect
            
            withAnimation(
                .easeIn(duration: finalDuration)
                .delay(initialDuration + Double.random(in: 0...0.2))
            ) {
                let index = particles.count - 1
                particles[index].position = CGPoint(x: finalX, y: finalY)
                particles[index].rotation += Double.random(in: 180...360)
            }
            
            // Fade out
            withAnimation(
                .easeIn(duration: 0.5)
                .delay(initialDuration + finalDuration - 0.3)
            ) {
                let index = particles.count - 1
                particles[index].opacity = 0
            }
        }
        
        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            particles.removeAll()
        }
    }
}

struct BookShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Book cover
        path.addRect(rect)
        
        // Book spine (20% from left)
        let spineLine = rect.width * 0.2
        path.move(to: CGPoint(x: spineLine, y: 0))
        path.addLine(to: CGPoint(x: spineLine, y: rect.height))
        
        // Add some page lines
        let pageGap = rect.height / 6
        for i in 1...4 {
            let y = pageGap * CGFloat(i)
            path.move(to: CGPoint(x: spineLine, y: y))
            path.addLine(to: CGPoint(x: rect.width - 4, y: y))
        }
        
        return path
    }
}

struct ParticleData: Identifiable {
    let id: UUID
    var position: CGPoint
    var rotation: Double
    let isBook: Bool
    var opacity: Double
    let color: Color
    let size: CGSize
} 