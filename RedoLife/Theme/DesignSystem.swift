import SwiftUI

struct AppColors {
    // Dark Liquid Palette
    static let background = Color(hex: "0D0E15") // Deep blue-black
    static let sidebarBG = Color(hex: "15161E")
    
    // Accents
    static let neonBlue = Color(hex: "4A90E2")
    static let softPurple = Color(hex: "BB86FC")
    static let electricTeal = Color(hex: "03DAC6")
    static let warmOrange = Color(hex: "CF6679")
    
    // Text
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.6)
}

struct AppGradients {
    static var deepLiquid: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "1A1B26"),
                Color(hex: "0D0E15")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func glassEffect(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: "1F212D").opacity(0.6))
            )
            .background(.thinMaterial) // SwiftUI material for blur
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LinearGradient(
                        colors: [.white.opacity(0.1), .white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)
    }
    
    func roundedFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> some View {
        self.font(.system(style, design: .rounded).weight(weight))
    }
}

extension Text {
    func roundedFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Text {
        self.font(.system(style, design: .rounded).weight(weight))
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
