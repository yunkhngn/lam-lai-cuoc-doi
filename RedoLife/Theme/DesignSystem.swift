import SwiftUI

// MARK: - Ultra Minimal Palette
struct AppColors {
    // Core
    static let white = Color.white
    static let lightGray = Color(hex: "F5F5F7")
    static let mediumGray = Color(hex: "86868B")
    static let darkGray = Color(hex: "1D1D1F")
    
    // Accent
    static let accent = Color(hex: "007AFF")
    static let green = Color(hex: "34C759")
    
    // Semantic
    static let bgPrimary = lightGray
    static let bgCard = white
    static let textPrimary = darkGray
    static let textMuted = mediumGray
    
    // Compatibility
    static let forest = darkGray
    static let sage = mediumGray
    static let cream = white
    static let offWhite = lightGray
    static let tan = accent
}

// MARK: - View Modifiers
extension View {
    func card(padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(AppColors.bgCard)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 12, y: 2)
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

// MARK: - Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
