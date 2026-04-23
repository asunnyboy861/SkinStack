import SwiftUI

extension Color {
    static let skinStackPrimary = Color(red: 0.91, green: 0.51, blue: 0.54)
    static let skinStackPrimaryLight = Color(red: 0.96, green: 0.71, blue: 0.73)
    static let skinStackSecondary = Color(red: 0.61, green: 0.56, blue: 0.77)
    static let skinStackSecondaryLight = Color(red: 0.83, green: 0.80, blue: 0.91)
    static let skinStackConflict = Color(red: 0.91, green: 0.36, blue: 0.36)
    static let skinStackCaution = Color(red: 0.94, green: 0.66, blue: 0.25)
    static let skinStackSafe = Color(red: 0.36, green: 0.77, blue: 0.49)
    static let skinStackBackground = Color(red: 1.0, green: 0.97, blue: 0.96)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
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
