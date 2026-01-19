import SwiftUI

// MARK: - Peaceful & Caring Palette
struct AppColors {
    // Primary
    static let forest = Color(hex: "193C1F")      // Dark forest green - accent
    static let sage = Color(hex: "8EA087")        // Sage green - secondary
    
    // Neutrals
    static let tan = Color(hex: "D1B698")         // Warm tan - highlights
    static let cream = Color(hex: "EDE4D8")       // Cream - cards
    static let lightSage = Color(hex: "D0D5CB")   // Light sage - borders
    static let offWhite = Color(hex: "F7F3ED")    // Off-white - background
    
    // Semantic
    static let bgPrimary = offWhite
    static let bgCard = cream
    static let accent = forest
    static let accentSecondary = sage
    static let textPrimary = forest
    static let textMuted = sage
}

// MARK: - View Modifiers
extension View {
    func card(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(AppColors.bgCard)
            .cornerRadius(16)
            .shadow(color: AppColors.forest.opacity(0.05), radius: 8, y: 4)
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
