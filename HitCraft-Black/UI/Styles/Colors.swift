// File: HitCraft-Black/UI/Styles/Colors.swift

import SwiftUI

enum HitCraftColors {
    // MARK: - Background colors
    
    // Main background color
    static var background: Color {
        ColorUtils.color(hex: "121212") // Dark background
    }
    
    // Chat background
    static var chatBackground: Color {
        ColorUtils.color(hex: "2e2e2c") // Chat background as specified
    }
    
    // Card and component backgrounds
    static var cardBackground: Color {
        ColorUtils.color(hex: "1E1E1E") // Darker card background
    }
    
    // Message backgrounds - exact colors as specified
    static var userMessageBackground: Color {
        ColorUtils.color(hex: "1d1d1c") // User message background
    }
    
    static var systemMessageBackground: Color {
        ColorUtils.color(hex: "383835") // System message background
    }
    
    // Header background color
    static var headerBackground: Color {
        ColorUtils.color(hex: "21211f") // Header background as specified
    }
    
    // MARK: - Text colors
    
    // Primary text
    static var text: Color {
        Color.white
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
        ColorUtils.color(hex: "21211f") // Updated to match header color
    }
    
    // Input background
    static var inputBackground: Color {
        ColorUtils.color(hex: "3d3c3a") // Input field background
    }
    
    // MARK: - Fixed Colors
    
    // Primary accent color
    static let accent = ColorUtils.color(hex: "d6307a") // Pink/purple accent
    
    // Secondary accent color (for hover/pressed states)
    static let accentHover = ColorUtils.color(hex: "e74d93") // Lighter version
    
    // Primary gradient
    static let primaryGradient = LinearGradient(
        colors: [ColorUtils.color(hex: "d6307a"), ColorUtils.color(hex: "e74d93")],
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
