import SwiftUI

struct ProgressCircleView: View {
    var progress: Double
    var size: CGFloat = 120
    var lineWidth: CGFloat = 12
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: progress)
            
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .contentTransition(.numericText(value: progress * 100))
            }
        }
        .frame(width: size, height: size)
    }
}
