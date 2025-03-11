// File: HitCraft-Black/Core/MainRootView.swift

import SwiftUI

struct MainRootView: View {
    @EnvironmentObject private var authService: HCAuthService
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab: MenuTab = .chat
    @State private var defaultArtist = ArtistProfile.sample
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content based on selected tab
            mainContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Menu Bar
            BottomMenuBar(selectedTab: $selectedTab) {
                selectedTab = .chat
                NotificationCenter.default.post(name: NSNotification.Name("RefreshChat"), object: nil)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToTab"))) { notification in
            if let tab = notification.userInfo?["tab"] as? MenuTab {
                selectedTab = tab
            }
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        switch selectedTab {
        case .history:
            HistoryView()
        case .chat:
            ChatView()
        case .productions:
            ProductionsView()
        case .settings:
            SettingsView()
        }
    }
}
