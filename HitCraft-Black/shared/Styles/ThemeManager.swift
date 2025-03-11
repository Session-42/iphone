import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    // Theme enum
    enum Theme: String, CaseIterable {
        case light, dark
        
        var displayName: String {
            self.rawValue.capitalized
        }
    }
    
    // Published property that views can observe
    @Published var currentTheme: Theme = .dark // Default to dark theme
    
    // Singleton instance
    static let shared = ThemeManager()
    
    // Theme Colors
    static var headerBackgroundColor: Color {
        // Use color #21211f for dark theme header
        return shared.currentTheme == .dark ? Color(red: 33/255, green: 33/255, blue: 31/255) : Color(red: 245/255, green: 245/255, blue: 245/255)
    }
    
    static var chatBackgroundColor: Color {
        // Use color #2e2e2c for dark theme chat background
        return shared.currentTheme == .dark ? Color(red: 46/255, green: 46/255, blue: 44/255) : Color(red: 240/255, green: 240/255, blue: 240/255)
    }
    
    // Private initializer for singleton
    private init() {
        // Always initialize with dark theme by default
        self.currentTheme = .dark
        
        // Force dark mode at system level too
        setAppearance()
    }
    
    // Set the app's appearance based on the selected theme
    private func setAppearance() {
        // For iOS 13+, force the theme regardless of system settings
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = currentTheme == .dark ? .dark : .light
        }
    }
    
    // Method to change theme
    func setTheme(_ theme: Theme) {
        currentTheme = theme
        setAppearance()
    }
}
