import SwiftUI

struct FloatingBook: Identifiable {
    let id = UUID()
    var position: CGPoint
    var rotation: Double
    var scale: Double
    var opacity: Double
    var delay: Double
}

struct SparkleView: View {
    let position: CGPoint
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.1
    let theme: AppTheme
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 12))
            .foregroundColor(theme.primary.opacity(0.6))
            .position(position)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 1
                    scale = 1
                }
                withAnimation(.easeIn(duration: 0.4).delay(0.4)) {
                    opacity = 0
                    scale = 0.1
                }
            }
    }
}

struct LaunchView: View {
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @Binding var showLaunch: Bool
    let theme: AppTheme
    
    @State private var books: [FloatingBook] = []
    @State private var sparkles: [UUID: [CGPoint]] = [:]
    
    func createBooks() -> [FloatingBook] {
        var books: [FloatingBook] = []
        for i in 0..<15 {  // A few more books for better effect
            books.append(FloatingBook(
                position: CGPoint(
                    x: CGFloat.random(in: -30 ... 30),  // Start closer together
                    y: CGFloat.random(in: 0 ... 50)     // Start more clustered
                ),
                rotation: Double.random(in: -30 ... 30), // Less initial rotation
                scale: 0.1,
                opacity: 0,
                delay: Double(i) * 0.2  // More delay between books
            ))
        }
        return books
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                theme.background
                    .ignoresSafeArea()
                
                // Floating Books
                ForEach(books) { book in
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 30))
                        .foregroundColor(theme.primary)
                        .position(
                            x: geometry.size.width/2 + book.position.x,
                            y: geometry.size.height/2 + book.position.y
                        )
                        .rotationEffect(.degrees(book.rotation))
                        .scaleEffect(book.scale)
                        .opacity(book.opacity)
                }
                
                // Title Image
                VStack {
                    Image("bookshelf-title")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .foregroundColor(Color(hex: "8B4513"))
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
        }
        .onAppear {
            books = createBooks()
            
            withAnimation(.easeOut(duration: 1.2)) {
                opacity = 1
                scale = 1
            }
            
            // Animate books
            for (index, book) in books.enumerated() {
                withAnimation(
                    .spring(response: 1.8, dampingFraction: 0.9)  // Even slower, smoother animation
                    .delay(0.8 + book.delay)
                ) {
                    books[index].scale = 1
                    books[index].opacity = 1
                    
                    // Calculate a more direct path with slight curve
                    let angle = Double.random(in: 0 ... 2 * .pi)  // Random direction
                    let distance = CGFloat.random(in: 400 ... 600) // Distance to travel
                    
                    let endX = cos(angle) * distance
                    let endY = sin(angle) * distance
                    
                    books[index].position = CGPoint(x: endX, y: endY)
                    books[index].rotation += Double.random(in: -60 ... 60)  // Less rotation
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {  // Longer duration
                withAnimation(.easeIn(duration: 1.2)) {  // Slower fade out
                    opacity = 0
                    scale = 1.1
                    for index in books.indices {
                        books[index].opacity = 0
                        books[index].scale = 0.5
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showLaunch = false
                }
            }
        }
    }
} 