import SwiftUI

struct TypingIndicator: View {
    @State private var dotOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 6, height: 6)
                    .offset(y: dotOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: dotOffset
                    )
            }
        }
        .onAppear {
            dotOffset = -5
        }
    }
}

#Preview {
    HStack {
        Text("Typing")
            .font(HitCraftFonts.caption())
            .foregroundColor(HitCraftColors.secondaryText)
        TypingIndicator()
    }
    .padding()
    .background(HitCraftColors.chatBackground)
}
