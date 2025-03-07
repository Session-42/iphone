// File: HitCraft-Black/UI/Styles/ThemeManager.swift

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
    @Published var currentTheme: Theme = .dark // Always use dark theme
    
    // Singleton instance
    static let shared = ThemeManager()
    
    // Private initializer for singleton
    private init() {
        // Always initialize with dark theme
        self.currentTheme = .dark
        
        // Force dark mode at system level too
        setAppearance()
    }
    
    // Set the app's appearance based on the selected theme
    private func setAppearance() {
        // For iOS 13+, force dark mode
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = .dark
        }
    }
}
