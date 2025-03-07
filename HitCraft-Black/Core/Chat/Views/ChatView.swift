import SwiftUI
import Foundation

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @State private var error: HCNetwork.Error?
    @State private var showError = false
    @State private var isLoadingMessages = true
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var keyboardHeight: CGFloat = 0
    @State private var bottomPadding: CGFloat = 80 // Increased padding space above the message bar
    
    let artistId: String
    private let chatService = ChatService.shared
    
    // Use the specific color for the header background
    private let headerColor = Color(hex: "3d3c3a")
    
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
                        
                        // Invisible spacer at the bottom with increased height
                        Color.clear
                            .frame(height: bottomPadding)
                            .id("bottomSpacer")
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of: messages) { _ in
                    scrollToBottom(proxy: proxy, animated: true)
                }
                .onChange(of: isTyping) { newValue in
                    if newValue {
                        // If typing indicator appears, scroll to it
                        scrollToTypingIndicator(proxy: proxy)
                    }
                }
                .onAppear {
                    self.scrollViewProxy = proxy
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height
                        // When keyboard appears, ensure we scroll to the bottom
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scrollToBottom(proxy: proxy, animated: true)
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    self.keyboardHeight = 0
                }
            }
            .background(Color(hex: "121212")) // Dark background
            
            // Custom Input Bar with embedded send button
            ChatInput(
                text: $messageText,
                placeholder: "Type your message...",
                isTyping: isTyping,
                onSend: sendMessage
            )
        }
        .task {
            await loadInitialChat()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
                .foregroundColor(Color.white)
        }
    }
    
    // MARK: - Helper Methods
    
    // This method fixes the "Value of type 'ChatView' has no member 'scrollToBottom'" error
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
    
    // This method fixes the "Value of type 'ChatView' has no member 'scrollToTypingIndicator'" error
    private func scrollToTypingIndicator(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo("typingIndicator", anchor: .bottom)
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
                timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
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
            // Handle errors like "No chat history available"
            self.error = error as? HCNetwork.Error ?? HCNetwork.Error.networkError(error)
            showError = true
            isLoadingMessages = false
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userText = messageText
        messageText = ""
        
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
            }
        }
    }
}
