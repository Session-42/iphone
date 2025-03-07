// File: HitCraft-Black/UI/Components/MessageBubble.swift

import SwiftUI

struct MessageBubble: View {
    let isFromUser: Bool
    let text: String
    
    // Specific colors as required
    private let userBubbleColor = Color(hex: "1d1d1c")
    private let systemBubbleColor = Color(hex: "383835")
    private let backgroundColor = Color(hex: "2e2e2c")
    private let textColor = Color(hex: "F5F4EF")
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isFromUser {
                // User message with avatar on left, inside the bubble
                HStack(alignment: .center, spacing: 10) {
                    // User avatar
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color.gray.opacity(0.7))
                        .padding(.leading, 12)
                    
                    // Message text, vertically centered
                    Text(text)
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 16)
                        .padding(.trailing, 16)
                        .frame(minHeight: 60, alignment: .center)
                }
                .background(userBubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                Spacer() // Push user message to left
            } else {
                // System message - maintaining full width
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(textColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(systemBubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(backgroundColor)
    }
}
