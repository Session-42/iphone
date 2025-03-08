import SwiftUI

struct MessageBubble: View {
    let isFromUser: Bool
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                if isFromUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(text)
                        .font(HitCraftFonts.body())
                        .foregroundColor(HitCraftColors.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isFromUser {
                    Spacer(minLength: 32)
                }
            }
            .padding(HitCraftLayout.messagePadding)
            .frame(maxWidth: .infinity)
            .background(isFromUser ? HitCraftColors.userMessageBackground : HitCraftColors.systemMessageBackground)
            .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.messageBubbleRadius))
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageBubble(isFromUser: true, text: "Hey, this is a test message from the user. How does it look?")
        MessageBubble(isFromUser: false, text: "This is a response from the assistant that might be a bit longer to test how the bubble handles multiple lines of text.")
    }
    .padding()
    .background(HitCraftColors.chatBackground)
}
