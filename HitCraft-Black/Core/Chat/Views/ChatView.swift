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
    
    let artistId: String
    var showInputField: Bool = true
    
    var body: some View {
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

            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
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
                        
                        // Invisible spacer at the bottom
                        Color.clear
                            .frame(height: bottomPadding)
                            .id("bottomSpacer")
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, showInputField ? 0 : 16)
                }
                .onChange(of: chatManager.scrollTrigger) { _ in
                    // When ChatPersistenceManager triggers a scroll
                    if let targetId = chatManager.scrollTarget {
                        print("🔄 Scrolling to: \(targetId) with anchor: \(chatManager.scrollAnchor)")
                        
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(targetId, anchor: chatManager.scrollAnchor)
                        }
                        
                        // Double-check scroll after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            proxy.scrollTo(targetId, anchor: chatManager.scrollAnchor)
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
                    } else {
                        // If already initialized, trigger scroll to bottom
                        chatManager.triggerScrollToBottom()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height
                        
                        // When keyboard appears, scroll to maintain visibility
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            chatManager.triggerScrollToBottom()
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    self.keyboardHeight = 0
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
            .background(HitCraftColors.chatBackground)
            .padding(.bottom, showInputField ? -16 : 0)
            
            // Only include the input field if showInputField is true
            if showInputField {
                // Custom Input Bar with embedded send button
                ChatInput(
                    text: $messageText,
                    placeholder: "Type your message...",
                    isTyping: chatManager.isTyping,
                    onSend: sendMessage
                )
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An error occurred")
                .foregroundColor(HitCraftColors.text)
        }
    }
    
    // Method to send a message from inside the view
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userText = messageText
        messageText = ""
        
        sendMessage(text: userText)
    }
    
    // Method that can be called externally or internally
    func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        
        // Use the persistence manager to send the message
        Task {
            await chatManager.sendMessage(text: text, artistId: artistId)
        }
    }
}
