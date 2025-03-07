// File: HitCraft-Black/UI/Views/ChatViewWithoutInput.swift

import SwiftUI
import Foundation

struct ChatViewWithoutInput: View {
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @State private var error: HCNetwork.Error?
    @State private var showError = false
    @State private var isLoadingMessages = true
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    
    let artistId: String
    private let chatService = ChatService.shared
    
    // The specific colors as requested
    private let headerColor = Color(hex: "21211f")
    private let backgroundColor = Color(hex: "2e2e2c")
    
    var body: some View {
        ZStack(alignment: .top) {
            // Full background color behind everything
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with dark background that extends below the title
                ZStack {
                    // Dark background for header - extends down enough to include the title
                    headerColor
                        .frame(height: 60)
                        .edgesIgnoringSafeArea(.top)
                    
                    // Title and button content
                    VStack(spacing: 0) {
                        // Status bar spacer
                        Spacer().frame(height: 20)
                        
                        // CHAT title perfectly centered, with button to the right
                        HStack {
                            // Empty spacer that's exactly the same width as the button on the right
                            // This ensures the CHAT title is truly centered
                            Spacer().frame(width: 44)
                            
                            Spacer()
                            Text("CHAT")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.white)
                            Spacer()
                            
                            // New chat button
                            Button(action: {
                                Task {
                                    ChatService.shared.activeThreadId = nil
                                    await loadInitialChat()
                                }
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20))
                                    .foregroundColor(HitCraftColors.accent)
                            }
                            .frame(width: 44)
                            .padding(.trailing, 20)
                            .hitCraftStyle()
                        }
                        .frame(height: 40)
                    }
                }
                
                // Chat messages area
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Message content
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
                                    }
                                }
                                
                                if isTyping {
                                    // Typing indicator with jumping dots
                                    MessageTypingBubble()
                                        .id("typingIndicator")
                                        .transition(.opacity)
                                }
                                
                                // Bottom spacer to ensure content doesn't sit right at the edge
                                Color.clear.frame(height: 20)
                                    .id("bottomSpacer")
                            }
                            .padding(.vertical, 16)
                        }
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
                            // Check if we already have an active thread
                            if ChatService.shared.activeThreadId != nil {
                                await loadChatHistory()
                            } else {
                                // Only load initial chat if this is a fresh start
                                await loadInitialChat()
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
                            await loadInitialChat()
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
                .foregroundColor(Color.white)
        }
    }
    
    // MARK: - Helper Methods
    
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                } else if isTyping {
                    proxy.scrollTo("typingIndicator", anchor: .bottom)
                } else {
                    proxy.scrollTo("bottomSpacer", anchor: .bottom)
                }
            }
        } else {
            if let lastMessage = messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            } else if isTyping {
                proxy.scrollTo("typingIndicator", anchor: .bottom)
            } else {
                proxy.scrollTo("bottomSpacer", anchor: .bottom)
            }
        }
    }
    
    private func scrollToTypingIndicator(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo("typingIndicator", anchor: .bottom)
        }
    }
    
    // Load chat history for resuming
    func loadChatHistory() async {
        isLoadingMessages = true
        
        do {
            let historyMessages = try await chatService.getChatHistory(artistId: artistId)
            
            if historyMessages.isEmpty {
                // If no history found, start new chat
                await loadInitialChat()
                return
            }
            
            isLoadingMessages = false
            
            // Use a simple animation approach to avoid NaN errors
            withAnimation(.easeIn(duration: 0.3)) {
                messages = historyMessages
            }
            
            // Scroll to bottom after loading messages
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let scrollViewProxy = self.scrollViewProxy {
                    self.scrollToBottom(proxy: scrollViewProxy, animated: true)
                }
            }
        } catch {
            // If error, fall back to new chat
            await loadInitialChat()
        }
    }
    
    func loadInitialChat() async {
        isLoadingMessages = true
        
        do {
            // Create a new chat with welcome message
            let message = try await chatService.sendMessage(
                text: "Hello, I'd like to create music",
                artistId: artistId
            )
            
            // Add an initial welcome message
            let welcomeMessage = ChatMessage(
                content: "Welcome! I'm HitCraft, your AI music assistant. How can I help with your music today?",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-1) // 1 second ago
            )
            
            isLoadingMessages = false
            
            // Use a simple animation approach to avoid NaN errors
            withAnimation(.easeIn(duration: 0.3)) {
                messages = [welcomeMessage, message]
            }
            
            // Scroll to bottom after loading messages
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let scrollViewProxy = self.scrollViewProxy {
                    self.scrollToBottom(proxy: scrollViewProxy, animated: true)
                }
            }
        } catch {
            // Handle errors
            self.error = error as? HCNetwork.Error ?? HCNetwork.Error.networkError(error)
            showError = true
            isLoadingMessages = false
            
            print("Error loading initial chat: \(error.localizedDescription)")
        }
    }
    
    private func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        
        let userText = text
        
        // Create user message
        let userMessage = ChatMessage(
            content: userText,
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
        
        // Ensure we scroll to the typing indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let scrollViewProxy = self.scrollViewProxy {
                self.scrollToTypingIndicator(proxy: scrollViewProxy)
            }
        }
        
        // Update the last active time
        UserDefaults.standard.set(Date(), forKey: "lastActiveTime")
        
        // Send message to API
        Task {
            do {
                // Add a small artificial delay to make it feel more natural
                try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
                
                let responseMessage = try await chatService.sendMessage(
                    text: userText,
                    artistId: artistId
                )
                
                // Hide typing indicator with animation
                withAnimation(.easeOut(duration: 0.2)) {
                    isTyping = false
                }
                
                // Short pause before showing the response
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                
                // Add the response message with animation
                withAnimation(.easeIn(duration: 0.3)) {
                    messages.append(responseMessage)
                }
                
                // Scroll to the new message
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let scrollViewProxy = self.scrollViewProxy {
                        self.scrollToBottom(proxy: scrollViewProxy, animated: true)
                    }
                }
            } catch {
                withAnimation {
                    isTyping = false
                }
                self.error = error as? HCNetwork.Error ?? HCNetwork.Error.networkError(error)
                showError = true
                
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Message Typing Bubble (with jumping dots)
struct MessageTypingBubble: View {
    // This recreates the original "jumping dots" typing indicator
    @State private var firstDotOffset: CGFloat = 0
    @State private var secondDotOffset: CGFloat = 0
    @State private var thirdDotOffset: CGFloat = 0
    
    private let systemBubbleColor = Color(hex: "383835")
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // System bubble with typing indicator dots
            HStack(spacing: 5) {
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .offset(y: firstDotOffset)
                
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .offset(y: secondDotOffset)
                
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .offset(y: thirdDotOffset)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(systemBubbleColor)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .onAppear {
            // Start the jumping animation
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                firstDotOffset = -7
            }
            
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.15)) {
                secondDotOffset = -7
            }
            
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3)) {
                thirdDotOffset = -7
            }
        }
    }
}
