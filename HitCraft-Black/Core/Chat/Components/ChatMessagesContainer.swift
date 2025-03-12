import SwiftUI

struct ChatMessagesContainer: View {
    @ObservedObject var chatManager: ChatPersistenceManager
    let isLoading: Bool
    let bottomPadding: CGFloat
    let showInputField: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    if isLoading {
                        loadingView
                    } else if chatManager.messages.isEmpty {
                        emptyStateView
                    } else {
                        messagesContent
                    }
                    
                    if chatManager.isTyping {
                        typingIndicatorView
                    }
                    
                    Color.clear
                        .frame(height: bottomPadding)
                        .id("bottomSpacer")
                }
                .padding(.vertical, 16)
                .padding(.bottom, showInputField ? 0 : 16)
            }
            .onChange(of: chatManager.scrollTrigger) { _ in
                if let targetId = chatManager.scrollTarget {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(targetId, anchor: chatManager.scrollAnchor)
                    }
                }
            }
        }
        .background(HitCraftColors.chatBackground)
        .padding(.bottom, showInputField ? -16 : 0)
    }
    
    private var messagesContent: some View {
        ForEach(chatManager.messages, id: \.id) { message in
            MessageBubble(associatedMessage: message)
                .id(message.id)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.98).combined(with: .opacity),
                    removal: .opacity
                ))
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .padding()
    }
    
    private var emptyStateView: some View {
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
    }
    
    private var typingIndicatorView: some View {
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
}