import SwiftUI

struct ChatMessagesContainer: View {
    @ObservedObject var chatManager: ChatPersistenceManager
    let isLoading: Bool
    let bottomPadding: CGFloat
    let showInputField: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                MessageListView(
                    messages: chatManager.messages,
                    isLoading: isLoading,
                    isTyping: chatManager.isTyping,
                    bottomPadding: bottomPadding
                )
                .padding(.bottom, showInputField ? 0 : 16)
            }
            .onChange(of: chatManager.scrollTrigger) { _ in
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
        }
        .background(HitCraftColors.chatBackground)
        .padding(.bottom, showInputField ? -16 : 0)
    }
} 