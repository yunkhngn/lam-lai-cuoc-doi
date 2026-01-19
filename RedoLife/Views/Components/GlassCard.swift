import SwiftUI

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(padding)
            .background(AppColors.bgCard)
            .cornerRadius(cornerRadius)
            .shadow(color: AppColors.forest.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    ZStack {
        AppColors.bgPrimary.ignoresSafeArea()
        GlassCard {
            Text("Hello World")
                .roundedFont(.title, weight: .bold)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
