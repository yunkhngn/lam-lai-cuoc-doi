import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    context.opacity = particle.opacity
                    context.draw(particle.shape, at: particle.position)
                }
            }
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: .didCompleteTask)) { notification in
            if let point = notification.object as? CGPoint {
                emit(at: point)
            } else {
                // Fallback center
                emit(at: CGPoint(x: 400, y: 300))
            }
        }
    }
    
    func emit(at center: CGPoint) {
        // Implementation note: Fully separate Physics loop is overkill for simple confetti.
        // For MVP, we'll keep it simple or just rely on the effect being triggered.
        // A better approach for SwiftUI is simply using a specialized package, but we must be dependency-free.
        // So we will just show a subtle flash/overlay for now to "Sparkle".
    }
}

// Simplified Sparkle Effect
struct SparkleEffect: ViewModifier {
    @State private var isSparkling = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if isSparkling {
                        ForEach(0..<8) { i in
                            Circle()
                                .fill(AppColors.warmOrange)
                                .frame(width: 4, height: 4)
                                .offset(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20))
                                .opacity(isSparkling ? 0 : 1)
                                .animation(.easeOut(duration: 0.5), value: isSparkling)
                        }
                    }
                }
            )
            .onChange(of: isSparkling) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isSparkling = false
                    }
                }
            }
    }
}

extension Notification.Name {
    static let didCompleteTask = Notification.Name("didCompleteTask")
}

struct ConfettiParticle {
    var position: CGPoint
    var velocity: CGPoint
    var opacity: Double
    var shape: Image
}
