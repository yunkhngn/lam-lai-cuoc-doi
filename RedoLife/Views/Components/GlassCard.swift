import SwiftUI

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 20
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(padding)
            .glassEffect(cornerRadius: cornerRadius)
    }
}

#Preview {
    ZStack {
        AppGradients.deepLiquid.ignoresSafeArea()
        GlassCard {
            Text("Hello World")
                .roundedFont(.title, weight: .bold)
        }
    }
}
