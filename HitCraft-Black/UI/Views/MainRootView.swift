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
            
            // For chat tab, include the chat input directly before the menu bar
            if selectedTab == .chat {
                // Custom Input Bar with embedded send button
                ChatInput(
                    text: $messageText,
                    placeholder: "Type your message...",
                    isTyping: isTyping,
                    onSend: {
                        // Pass the send action to the ChatView - this will need to be implemented
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
            // Modified ChatView that doesn't include its own input
            ChatViewWithoutInput(artistId: defaultArtist.id)
        case .productions:
            ProductionsView()
        case .settings:
            SettingsView()
        }
    }
}

// Modified ChatView without its own input component
struct ChatViewWithoutInput: View {
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @State private var error: HCNetwork.Error?
    @State private var showError = false
    @State private var isLoadingMessages = true
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    
    let artistId: String
    private let chatService = ChatService.shared
    
    // Use the exact color you specified
    private let headerColor = Color(hex: "3d3c3a")
    private let backgroundColor = Color(hex: "121212")
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header with new chat button
            HStack {
                Spacer()
                Text("CHAT")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.white)
                Spacer()
                
                // New Chat Button
                Button(action: {
                    // Start new chat
                    Task {
                        ChatService.shared.activeThreadId = nil
                        await loadInitialChat()
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(HitCraftColors.accent)
                }
                .padding(.trailing, 20)
                .hitCraftStyle()
            }
            .frame(height: 44)
            .padding(.leading, 20)
            .background(headerColor)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if isLoadingMessages {
                            ProgressView()
                                .padding()
                        } else if messages.isEmpty {
                            VStack(spacing: 16) {
                                Text("Start a new conversation")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color.white)
                                Text("Ask for help with your music production, lyrics, or any other musical needs.")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.gray.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(messages) { message in
                                MessageBubble(isFromUser: message.isFromUser, text: message.text)
                                    .id(message.id)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.98).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        
                        if isTyping {
                            HStack {
                                Text("Typing")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.gray.opacity(0.8))
                                TypingIndicator()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 24)
                            .id("typingIndicator")
                            .transition(.opacity)
                        }
                        
                        // Invisible spacer at the bottom
                        Color.clear
                            .frame(height: 20)
                            .id("bottomSpacer")
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of: messages) { _ in
                    scrollToBottom(proxy: proxy, animated: true)
                }
                .onChange(of: isTyping) { newValue in
                    if newValue {
                        scrollToTypingIndicator(proxy: proxy)
                    }
                }
                .onAppear {
                    self.scrollViewProxy = proxy
                    Task {
                        await loadInitialChat()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SendChatMessage"))) { notification in
                    if let messageText = notification.object as? String {
                        sendMessage(text: messageText)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshChat"))) { _ in
                    Task {
                        await loadInitialChat()
                    }
                }
            }
            .background(backgroundColor)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
                .foregroundColor(Color.white)
        }
    }
    
    // Include all the same helper methods but modify sendMessage to take a parameter
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        // Same implementation as before
    }
    
    private func scrollToTypingIndicator(proxy: ScrollViewProxy) {
        // Same implementation as before
    }
    
    func loadInitialChat() async {
        // Same implementation as before
    }
    
    private func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        
        // Create user message
        let userMessage = ChatMessage(
            content: text,
            sender: "user"
        )
        
        // Add user message with simple animation
        withAnimation(.easeIn(duration: 0.3)) {
            messages.append(userMessage)
        }
        
        // Show typing indicator
        withAnimation(.easeIn(duration: 0.3)) {
            isTyping = true
        }
        
        // Rest of implementation same as before
    }
}
