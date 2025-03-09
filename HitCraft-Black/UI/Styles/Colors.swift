import SwiftUI

enum HitCraftColors {
    // MARK: - Background colors
    
    // Main background color
    static var background: Color {
        ColorUtils.color(hex: "121212") // Dark background
    }
    
    // Card and component backgrounds
    static var cardBackground: Color {
        ColorUtils.color(hex: "1d1d1c") // Updated darker card background
    }
    
    // History view background
    static var historyBackground: Color {
        ColorUtils.color(hex: "2e2e2c") // Specific history view background
    }
    
    // Message backgrounds
    static var userMessageBackground: Color {
        ColorUtils.color(hex: "1d1d1c") // Updated user message background
    }
    
    static var systemMessageBackground: Color {
        ColorUtils.color(hex: "383835") // Updated system message background
    }
    
    // Chat backgrounds - NEW
    static var headerBackground: Color {
        ColorUtils.color(hex: "21211f") // Dark header background
    }
    
    static var chatBackground: Color {
        ColorUtils.color(hex: "2e2e2c") // Dark chat background
    }
    
    static var chatInputBackground: Color {
        ColorUtils.color(hex: "3d3c3a") // Dark input background
    }
    
    // MARK: - Text colors
    
    // Primary text
    static var text: Color {
        ColorUtils.color(hex: "F5F4EF") // Light text
    }
    
    // Secondary text
    static var secondaryText: Color {
        ColorUtils.color(hex: "B0B0B0") // Light gray
    }
    
    // MARK: - UI elements
    
    // Border color
    static var border: Color {
        ColorUtils.color(hex: "333333") // Dark border
    }
    
    // Header and footer areas
    static var headerFooterBackground: Color {
        ColorUtils.color(hex: "21211f") // Updated to match header
    }
    
    // MARK: - Fixed Colors (Same in both themes)
    
    // Primary accent color
    static let accent = ColorUtils.color(hex: "FF4A7D") // Pink accent
    
    // Secondary accent color (for hover/pressed states)
    static let accentHover = ColorUtils.color(hex: "FF6F92")
    
    // Primary gradient
    static let primaryGradient = LinearGradient(
        colors: [ColorUtils.color(hex: "FF4A7D"), ColorUtils.color(hex: "FF6F92")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // For backward compatibility
    static var darkAreaColor: Color {
        headerFooterBackground
    }
}

// Separate utility class to avoid extension conflicts
struct ColorUtils {
    // Convert hex string to Color
    static func color(hex: String) -> Color {
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
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
