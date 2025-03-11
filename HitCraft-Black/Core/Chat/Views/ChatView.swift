import SwiftUI
import Foundation

struct ChatView: View {
    // Use the shared persistence manager
    @ObservedObject private var chatManager = ChatPersistenceManager.shared
    @State private var messageText = ""
    @State private var error: HCNetwork.Error?
    @State private var showError = false
    @State private var isLoadingMessages = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var bottomPadding: CGFloat = 80
    
    // Track the last scroll event to prevent redundant scrolling
    @State private var lastScrollID = UUID()
    
    let artistId: String
    var showInputField: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Header with new chat button
                ZStack {
                    // Title centered on screen (placed in ZStack to center it properly)
                    Text("HitCraft")
                        .font(HitCraftFonts.header())
                        .foregroundColor(HitCraftColors.text)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Button positioned on the right side
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            // Start new chat
                            Task {
                                chatManager.clearChat()
                                isLoadingMessages = true
                                await chatManager.initializeChat(artistId: artistId)
                                isLoadingMessages = false
                            }
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundColor(HitCraftColors.accent)
                                .padding(.bottom, 3) // Bottom padding for alignment
                        }
                        .padding(.trailing, 20)
                        .hitCraftStyle()
                    }
                }
                .frame(height: 44)
                .background(HitCraftColors.headerBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .zIndex(1) // Keep header on top

                // Chat Messages - use remaining height minus keyboard space
                ScrollViewReader { proxy in
                    ScrollView {
                        // Top spacer to prevent content from being under the header
                        Color.clear
                            .frame(height: 5)
                            .id("topSpacer")
                        
                        LazyVStack(spacing: 10) {
                            if isLoadingMessages {
                                ProgressView()
                                    .padding()
                            } else if chatManager.messages.isEmpty {
                                VStack(spacing: 16) {
                                    Text("Start a new conversation")
                                        .font(HitCraftFonts.subheader())
                                        .foregroundColor(HitCraftColors.text)
                                    Text("Ask for help with your music production, lyrics, or any other musical needs.")
                                        .font(HitCraftFonts.body())
                                        .foregroundColor(HitCraftColors.secondaryText)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .padding(.top, 100)
                            } else {
                                ForEach(chatManager.messages) { message in
                                    MessageBubble(
                                        isFromUser: message.isFromUser,
                                        text: message.text,
                                        associatedMessage: message
                                    )
                                    .id(message.id.uuidString)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.98).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                }
                            }
                            
                            if chatManager.isTyping {
                                HStack {
                                    Text("Typing")
                                        .font(HitCraftFonts.caption())
                                        .foregroundColor(HitCraftColors.secondaryText)
                                    TypingIndicator()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 24)
                                .id("typingIndicator")
                                .transition(.opacity)
                            }
                            
                            // Extra padding at the bottom to ensure content stays visible above keyboard
                            Color.clear
                                .frame(height: max(bottomPadding, keyboardHeight + 60)) // Add extra padding
                                .id("bottomSpacer")
                        }
                        .padding(.vertical, 16)
                        .padding(.bottom, showInputField ? 0 : 16)
                    }
                    // Watch for scroll triggers from ChatPersistenceManager
                    .onChange(of: chatManager.scrollTrigger) { newValue in
                        // Prevent redundant scrolling
                        if lastScrollID != newValue, let targetID = chatManager.scrollTarget {
                            lastScrollID = newValue
                            
                            // Use a small delay to ensure the view is updated before scrolling
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                // Perform the scroll with the specified anchor
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(targetID, anchor: chatManager.scrollAnchor)
                                }
                            }
                        }
                    }
                    .onAppear {
                        // Initialize chat if needed
                        if !chatManager.isInitialized {
                            Task {
                                isLoadingMessages = true
                                await chatManager.initializeChat(artistId: artistId)
                                isLoadingMessages = false
                            }
                        } else if !chatManager.messages.isEmpty {
                            // If already initialized, trigger scroll to bottom
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                chatManager.triggerScrollToBottom()
                            }
                        }
                    }
                }
                .background(HitCraftColors.chatBackground)
                .padding(.bottom, showInputField ? -16 : 0)
                // Make scroll view adjust its frame smoothly based on keyboard height
                .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                    
                    // Use a slight delay to ensure UI updates before scrolling
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if let lastMessageID = chatManager.messages.last?.id.uuidString {
                            chatManager.triggerScrollTo(id: lastMessageID, anchor: .bottom)
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    self.keyboardHeight = 0
                }
                
                // Ensure proper scroll position after keyboard hides
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let lastMessageID = chatManager.messages.last?.id.uuidString {
                        chatManager.triggerScrollTo(id: lastMessageID, anchor: .bottom)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SendChatMessage"))) { notification in
                if let messageText = notification.object as? String {
                    sendMessage(text: messageText)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshChat"))) { _ in
                Task {
                    chatManager.clearChat()
                    isLoadingMessages = true
                    await chatManager.initializeChat(artistId: artistId)
                    isLoadingMessages = false
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
                .foregroundColor(HitCraftColors.text)
        }
    }
    
    // Method to send a message
    func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        
        // Use the persistence manager to send the message
        Task {
            await chatManager.sendMessage(text: text, artistId: artistId)
        }
    }
}
