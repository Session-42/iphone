// File: HitCraft-Black/UI/Views/MainRootView.swift

import SwiftUI

struct MainRootView: View {
    @EnvironmentObject private var authService: HCAuthService
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var defaultArtist = ArtistProfile.sample
    @State private var selectedTab: MenuTab = .chat
    @State private var previousTab: MenuTab = .chat // Track the previous tab
    @State private var error: Error?
    @State private var showError = false
    @State private var messageText = ""
    @State private var isTyping = false
    
    // Color constants
    private let headerColor = Color(hex: "21211f")
    private let backgroundColor = Color(hex: "2e2e2c")
    private let accentColor = Color(hex: "d6307a")
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area
            VStack(spacing: 0) {
                // Current view based on selected tab
                mainContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom controls
            VStack(spacing: 0) {
                // For chat tab, include the input area
                if selectedTab == .chat {
                    ChatInput(
                        text: $messageText,
                        placeholder: "Type your message...",
                        isTyping: isTyping,
                        onSend: {
                            // Don't send empty messages
                            guard !messageText.isEmpty else { return }
                            
                            // Pass the send action to the ChatView
                            NotificationCenter.default.post(
                                name: NSNotification.Name("SendChatMessage"),
                                object: messageText
                            )
                            messageText = ""
                        }
                    )
                }
                
                // Bottom menu bar - absolutely no spacing
                BottomMenuBar(selectedTab: $selectedTab, onStartNewChat: {
                    ChatService.shared.activeThreadId = nil
                    
                    // Only refresh if we're already on the chat tab
                    if selectedTab == .chat {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("RefreshChat"),
                            object: nil
                        )
                    }
                    
                    selectedTab = .chat
                })
            }
        }
        // Watch for tab changes and handle chat session persistence
        .onChange(of: selectedTab) { newTab in
            // Store the new selection time to track sessions
            UserDefaults.standard.set(Date(), forKey: "lastTabChangeTime")
            
            // Only trigger a refresh if we're returning to chat from another tab
            // and it's still the same session (no need to create a new chat)
            if newTab == .chat && previousTab != .chat {
                // We're returning to chat - but we don't need to refresh
                // Chat state is maintained by the ChatViewWithoutInput
            }
            
            // Update previous tab for next change
            previousTab = newTab
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToTab"))) { notification in
            if let tab = notification.userInfo?["tab"] as? MenuTab {
                selectedTab = tab
            }
        }
        .preferredColorScheme(.dark) // Ensure dark mode
        .accentColor(accentColor) // Apply accent color globally
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
        }
        .onAppear {
            // Record when the app was last active
            UserDefaults.standard.set(Date(), forKey: "lastActiveTime")
            
            // Initialize the previous tab to match the starting tab
            previousTab = selectedTab
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        switch selectedTab {
        case .history:
            HistoryView()
        case .chat:
            // ChatView that doesn't include its own input
            ChatViewWithoutInput(artistId: defaultArtist.id)
        case .productions:
            ProductionsView()
        case .settings:
            SettingsView()
        }
    }
}
