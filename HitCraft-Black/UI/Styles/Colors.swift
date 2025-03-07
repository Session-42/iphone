import SwiftUI

enum HitCraftColors {
    // MARK: - Dynamic Colors (Light/Dark aware)
    
    // Background colors
    static var background: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "121212") : Color(hex: "F2F2F2")
    }
    
    static var cardBackground: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "1E1E1E") : Color.white
    }
    
    static var userMessageBackground: Color {
        ThemeManager.shared.currentTheme == .dark ?
            Color(hex: "FF4A7D").opacity(0.15) : Color(hex: "FF4A7D").opacity(0.1)
    }
    
    static var systemMessageBackground: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "2A2A2A") : Color(hex: "F2F2F2")
    }
    
    // Text colors
    static var text: Color {
        ThemeManager.shared.currentTheme == .dark ? Color.white : Color(hex: "333333")
    }
    
    static var secondaryText: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "B0B0B0") : Color(hex: "666666")
    }
    
    // UI elements
    static var border: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "333333") : Color(hex: "E0E0E0")
    }
    
    static var headerFooterBackground: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "F9F9F9")
    }
    
    // MARK: - Fixed Colors (Same in both themes)
    
    // Primary colors
    static let accent = Color(hex: "FF4A7D")            // Primary Pink
    static let accentHover = Color(hex: "FF6F92")       // Secondary Pink (hover/pressed state)
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "FF4A7D"), Color(hex: "FF6F92")],
        startPoint: .leading,
        endPoint: .trailing
    )
}
