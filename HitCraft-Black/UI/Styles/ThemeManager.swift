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
    @Published var currentTheme: Theme {
        didSet {
            // Save the user's theme preference
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "userTheme")
            
            // Set system appearance if possible
            setAppearance()
        }
    }
    
    // Singleton instance
    static let shared = ThemeManager()
    
    // Private initializer for singleton
    private init() {
        // Load the saved theme or use system default
        if let savedTheme = UserDefaults.standard.string(forKey: "userTheme"),
           let theme = Theme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            // Use system default
            self.currentTheme = .light
        }
    }
    
    // Set the app's appearance based on the selected theme
    private func setAppearance() {
        // For iOS 13+, we have a way to influence the app's appearance
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = currentTheme == .dark ? .dark : .light
        }
    }
}
