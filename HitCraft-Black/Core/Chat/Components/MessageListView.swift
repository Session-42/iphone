import SwiftUI

struct MessageListView: View {
    let messages: [MessageData]
    let isLoading: Bool
    let isTyping: Bool
    let bottomPadding: CGFloat
    
    var body: some View {
        LazyVStack(spacing: 10) {
            if isLoading {
                ProgressView()
                    .padding()
            } else if messages.isEmpty {
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
                ForEach(Array(messages.enumerated()), id: \.1.timestamp) { index, message in
                    MessageBubble(associatedMessage: MessageResponse(message: message))
                    .id(UUID().uuidString)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.98).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            
            if isTyping {
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
    }
} 