// File: HitCraft-Black/ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: HCAuthService
    
    var body: some View {
        if authService.isAuthenticated {
            MainRootView()
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HCAuthService.shared)
            .environmentObject(ThemeManager.shared)
    }
}
