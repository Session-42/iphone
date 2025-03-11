import SwiftUI

struct HitCraftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Extension to make button style easier to apply
extension View {
    func hitCraftStyle() -> some View {
        self.buttonStyle(HitCraftButtonStyle())
    }
}

// Example of using HitCraftButtonStyle
#Preview {
    VStack(spacing: 20) {
        Button("Standard Button") { }
            .padding()
            .background(HitCraftColors.accent)
            .foregroundColor(.white)
            .cornerRadius(8)
            .hitCraftStyle()
        
        Button(action: {}) {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(12)
                .background(
                    Circle()
                        .fill(HitCraftColors.accent)
                )
        }
        .hitCraftStyle()
    }
    .padding()
    .background(HitCraftColors.background)
}
