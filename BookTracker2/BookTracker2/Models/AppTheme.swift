import SwiftUI

enum AppTheme: String, CaseIterable {
    case minimal
    case blue
    case purple
    case green
    case orange
    
    var primary: Color {
        switch self {
        case .minimal: return Color(hex: "493A35")
        case .blue: return .blue
        case .purple: return .purple
        case .green: return .green
        case .orange: return .orange
        }
    }
    
    var secondary: Color {
        switch self {
        case .minimal: return Color(hex: "B98E68")
        case .blue: return .cyan
        case .purple: return .pink
        case .green: return .mint
        case .orange: return .yellow
        }
    }
    
    var background: Color {
        switch self {
        case .minimal: return Color(hex: "F1EEE6")
        default: return Color(.systemBackground)
        }
    }
    
    var cardBackground: Color {
        switch self {
        case .minimal: return .white
        default: return Color(.secondarySystemBackground)
        }
    }
    
    var text: Color {
        switch self {
        case .minimal: return Color(hex: "353148")
        default: return Color(.label)
        }
    }
    
    var secondaryText: Color {
        switch self {
        case .minimal: return Color(hex: "D2CFC4")
        default: return Color(.secondaryLabel)
        }
    }
    
    var gradientColors: [Color] {
        [primary, secondary]
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "appTheme")
        currentTheme = AppTheme(rawValue: savedTheme ?? "") ?? .minimal
    }
}

// Helper for hex colors
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 