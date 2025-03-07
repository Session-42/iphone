import SwiftUI
import DescopeKit

@main
struct HitcraftApp: App {
    // Initialize auth service at app level
    @StateObject private var authService = AuthService.shared
    // Initialize theme manager to be available globally
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        // Initialize Descope with your project ID
        Descope.setup(projectId: "P2rIvbtGcXTcUfT68LGuVqPitlJd") { config in
            config.baseURL = "https://auth.dev.hitcraft.ai"
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ChatView(artistId: "default_artist_id")
            ContentView()
                .environmentObject(authService)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
        }
    }
}
