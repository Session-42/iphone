import SwiftUI
import WebKit

struct MessageBubble: View {
    let associatedMessage: MessageResponse
    
    init(associatedMessage: MessageResponse) {
        self.associatedMessage = associatedMessage
    }
    
    // Helper computed properties
    private var messageText: String {
        associatedMessage.message.content
            .filter { $0.type == "text" }
            .map { $0.text }
            .joined(separator: "\n")
    }
    
    private var isSingleLine: Bool {
        !messageText.contains("\n") && messageText.count < 50
    }
    
    private var isAssistantMessage: Bool {
        associatedMessage.message.role == "assistant"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isAssistantMessage {
                assistantMessageView
            } else {
                userMessageView
            }
        }
        .padding(.horizontal, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
    
    // Assistant message view
    private var assistantMessageView: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(messageText)
                    .font(HitCraftFonts.body())
                    .foregroundColor(HitCraftColors.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 32)
        }
        .padding(HitCraftLayout.messagePadding)
        .frame(maxWidth: .infinity)
        .background(HitCraftColors.systemMessageBackground)
        .overlay(assistantMessageBorder)
        .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.messageBubbleRadius))
        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
    
    // Assistant message border
    private var assistantMessageBorder: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(HitCraftColors.accent)
                    .frame(width: 5, height: 2)
                    .offset(x: 0)
                
                Rectangle()
                    .fill(HitCraftColors.accent)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                
                Rectangle()
                    .fill(HitCraftColors.accent)
                    .frame(width: 5, height: 2)
                    .offset(x: 0)
            }
            .padding(.vertical, 0)
            
            Spacer()
        }
    }
    
    // User message view
    private var userMessageView: some View {
        HStack(alignment: isSingleLine ? .center : .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(Color.gray.opacity(0.7))
            
            Text(messageText)
                .font(HitCraftFonts.body())
                .foregroundColor(HitCraftColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, isSingleLine ? 8 : 0)
        }
        .padding(HitCraftLayout.messagePadding)
        .frame(maxWidth: .infinity)
        .background(HitCraftColors.userMessageBackground)
        .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.messageBubbleRadius))
        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}