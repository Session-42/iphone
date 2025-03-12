import SwiftUI
import Foundation

struct ChatView: View {
    @ObservedObject private var chatManager = ChatPersistenceManager.shared
    @State private var messageText = ""
    @State private var error: HCNetwork.Error?
    @State private var showError = false
    @State private var isLoadingMessages = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var bottomPadding: CGFloat = 80
    
    private let artistId = ArtistProfile.sample.id
    private let showInputField = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header with new chat button
            ZStack {
                Text("HitCraft")
                    .font(HitCraftFonts.header())
                    .foregroundColor(HitCraftColors.text)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
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
                            .padding(.bottom, 3)
                    }
                    .padding(.trailing, 20)
                    .hitCraftStyle()
                }
            }
            .frame(height: 44)
            .background(HitCraftColors.headerBackground)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

            ChatMessagesContainer(
                chatManager: chatManager,
                isLoading: isLoadingMessages,
                bottomPadding: bottomPadding,
                showInputField: showInputField
            )
            
            if showInputField {
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
        .onAppear {
            if chatManager.isInitialized {
                chatManager.triggerScrollToBottom()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = keyboardFrame.height
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
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let userText = messageText
        messageText = ""
        sendMessage(text: userText)
    }
    
    func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        Task {
            await chatManager.sendMessage(text: text)
        }
    }
}
