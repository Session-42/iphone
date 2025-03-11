import SwiftUI

struct EmptyHistoryStateView: View {
    let onStartNewChat: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.fill")
                .font(.system(size: 50))
                .foregroundColor(HitCraftColors.secondaryText.opacity(0.3))
            
            Text("No Chat History")
                .font(HitCraftFonts.subheader())
                .foregroundColor(HitCraftColors.text)
            
            Text("Start a conversation to see your chat history here")
                .font(HitCraftFonts.body())
                .foregroundColor(HitCraftColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onStartNewChat) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Start New Chat")
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