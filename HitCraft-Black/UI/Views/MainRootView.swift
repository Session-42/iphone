// File: HitCraft-Black/Core/MainRootView.swift

import SwiftUI

struct MainRootView: View {
    @EnvironmentObject private var authService: HCAuthService
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var defaultArtist = ArtistProfile.sample
    @State private var selectedTab: MenuTab = .chat
    @State private var error: Error?
    @State private var showError = false
    @State private var messageText = ""
    @State private var isTyping = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content based on selected tab
            mainContentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Add negative padding if in chat tab to create overlap
                .padding(.bottom, selectedTab == .chat ? -16 : 0)
            
            // For chat tab, include the chat input directly before the menu bar
            if selectedTab == .chat {
                // Custom Input Bar with embedded send button
                ChatInput(
                    text: $messageText,
                    placeholder: "Type your message...",
                    isTyping: isTyping,
                    onSend: {
                        // Pass the send action to the ChatView
                        NotificationCenter.default.post(name: NSNotification.Name("SendChatMessage"), object: messageText)
                        messageText = ""
                    }
                )
            }
            
            // Bottom Menu Bar - no spacing between this and the input above
            BottomMenuBar(selectedTab: $selectedTab, onStartNewChat: {
                ChatService.shared.activeThreadId = nil
                selectedTab = .chat
                // Notify chat view to refresh
                NotificationCenter.default.post(name: NSNotification.Name("RefreshChat"), object: nil)
            })
        }
        .edgesIgnoringSafeArea(.bottom) // Extend to the bottom edge
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToTab"))) { notification in
            if let tab = notification.userInfo?["tab"] as? MenuTab {
                selectedTab = tab
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        switch selectedTab {
        case .history:
            HistoryView()
        case .chat:
            // Use the regular ChatView but with showInputField set to false
            ChatView(artistId: defaultArtist.id, showInputField: false)
        case .productions:
            ProductionsView()
        case .settings:
            SettingsView()
        }
    }
}
