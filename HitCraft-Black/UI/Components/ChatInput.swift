import SwiftUI

struct ChatInput: View {
    @Binding var text: String
    let placeholder: String
    let isTyping: Bool
    let onSend: () -> Void
    
    // Send button color
    private var sendButtonColor: Color {
        if text.isEmpty || isTyping {
            return Color.gray.opacity(0.6)
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Input field with embedded send button
            HStack(spacing: 0) {
                TextField(placeholder, text: $text)
                    .font(HitCraftFonts.body())
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                    .padding(.vertical, 12)
                    .foregroundColor(HitCraftColors.text)
                    .background(HitCraftColors.chatInputBackground)
                
                // Send button inside the input area
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(sendButtonColor)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        )
                        .padding(.trailing, 12)
                }
                .disabled(text.isEmpty || isTyping)
                .hitCraftStyle()
                .scaleEffect(isTyping ? 0.95 : 1.0)
            }
            .background(HitCraftColors.chatInputBackground)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(HitCraftColors.chatInputBackground)
        // Only rounded corners at the top
        .clipShape(
            RoundedCorners(topLeft: 16, topRight: 16, bottomLeft: 0, bottomRight: 0)
        )
    }
}

#Preview {
    VStack {
        Spacer()
        ChatInput(
            text: .constant("Hello there"),
            placeholder: "Type your message...",
            isTyping: false,
            onSend: {}
        )
    }
    .background(HitCraftColors.chatBackground)
}
