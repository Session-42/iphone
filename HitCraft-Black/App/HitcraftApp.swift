// File: HitCraft-Black/App/HitcraftApp.swift

import SwiftUI
import DescopeKit

@main
struct HitcraftApp: App {
    // Initialize auth service at app level
    @StateObject private var authService = HCAuthService.shared
    // Initialize theme manager to be available globally
    @StateObject private var themeManager = ThemeManager.shared
    // Initialize chat persistence manager
    @StateObject private var chatManager = ChatPersistenceManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(themeManager)
                .environmentObject(chatManager)
                .preferredColorScheme(.dark)
        }
    }
}
