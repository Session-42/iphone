// File: HitCraft-Black/UI/Components/EmptyStateView.swift

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(HitCraftColors.secondaryText.opacity(0.3))
            
            Text(title)
                .font(HitCraftFonts.subheader())
                .foregroundColor(HitCraftColors.text)
            
            Text(message)
                .font(HitCraftFonts.body())
                .foregroundColor(HitCraftColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: action) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(buttonText)
                }
                .padding()
                .frame(width: 220)
                .background(HitCraftColors.accent)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "clock.fill",
        title: "No Chat History",
        message: "Start a conversation to see your chat history here",
        buttonText: "Start New Chat"
    ) {
        print("Button tapped")
    }
    .background(HitCraftColors.background)
}
