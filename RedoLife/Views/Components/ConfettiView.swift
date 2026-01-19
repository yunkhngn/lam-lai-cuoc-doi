import SwiftUI

struct ConfettiView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: 8, height: 8)
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -100...100) : 0,
                        y: isAnimating ? CGFloat.random(in: -150...150) : 0
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .scaleEffect(isAnimating ? 0.5 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                isAnimating = true
            }
        }
    }
    
    private var colors: [Color] {
        [AppColors.forest, AppColors.sage, AppColors.tan]
    }
}

struct SparkleEffect: View {
    @State private var isSparkling = false
    
    var body: some View {
        ZStack {
            if isSparkling {
                ForEach(0..<8) { i in
                    Circle()
                        .fill(AppColors.tan)
                        .frame(width: 4, height: 4)
                        .offset(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20))
                        .opacity(isSparkling ? 0 : 1)
                        .animation(.easeOut(duration: 0.6).delay(Double(i) * 0.05), value: isSparkling)
                }
            }
        }
        .onAppear {
            isSparkling = true
        }
    }
}

#Preview {
    ConfettiView()
}
