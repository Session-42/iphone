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
            .overlay(
                Group {
                    if !isFromUser {
                        HStack(spacing: 0) {
                            // Left pink border
                            VStack(spacing: 0) {
                                // Top extension
                                Rectangle()
                                    .fill(HitCraftColors.accent)
                                    .frame(width: 5, height: 2)
                                    .offset(x: 0)
                                
                                // Vertical line
                                Rectangle()
                                    .fill(HitCraftColors.accent)
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                                
                                // Bottom extension
                                Rectangle()
                                    .fill(HitCraftColors.accent)
                                    .frame(width: 5, height: 2)
                                    .offset(x: 0)
                            }
                            .padding(.vertical, 0)
                            
                            Spacer()
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.messageBubbleRadius))
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}
