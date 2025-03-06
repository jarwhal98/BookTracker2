import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var scale: CGFloat
    var rotation: Double
    var color: Color
}

struct ConfettiView: View {
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    context.opacity = 0.8
                    context.blendMode = .plusLighter
                    
                    context.translateBy(x: particle.position.x, y: particle.position.y)
                    context.rotate(by: .degrees(particle.rotation))
                    context.scaleBy(x: particle.scale, y: particle.scale)
                    
                    // Larger confetti pieces
                    context.fill(
                        Path(CGRect(x: -3, y: -6, width: 6, height: 12)),
                        with: .color(particle.color)
                    )
                }
            }
        }
        .onAppear {
            startConfetti()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startConfetti() {
        // Create initial particles
        for _ in 0..<30 {
            createParticle()
        }
        
        // Slower update frequency
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updateParticles()
            if particles.count < 50 {
                createParticle()
            }
        }
    }
    
    private func createParticle() {
        let particle = Particle(
            position: CGPoint(x: CGFloat.random(in: 0...200), y: -50),  // Start above the card
            velocity: CGPoint(
                x: CGFloat.random(in: -1...1),  // Slower horizontal movement
                y: CGFloat.random(in: 0.5...2)  // Slower falling
            ),
            scale: CGFloat.random(in: 0.4...1.4),
            rotation: Double.random(in: 0...360),
            color: colors.randomElement() ?? .red
        )
        particles.append(particle)
    }
    
    private func updateParticles() {
        particles = particles.compactMap { particle in
            var newParticle = particle
            
            // Update position
            newParticle.position.x += particle.velocity.x
            newParticle.position.y += particle.velocity.y
            
            // Lighter gravity
            newParticle.velocity.y += 0.08
            
            // Slower rotation
            newParticle.rotation += Double.random(in: 1...4)
            
            // Very slight drift
            newParticle.velocity.x += CGFloat.random(in: -0.1...0.1)
            
            // Remove particles that have fallen off screen
            if newParticle.position.y > 400 {
                return nil
            }
            
            return newParticle
        }
    }
} 