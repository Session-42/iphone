import SwiftUI

// MARK: - Message Bubble
struct MessageBubble: View {
    let isFromUser: Bool
    let text: String
    
    // Updated bubble colors as specified
    private let userBubbleColor = Color(hex: "1d1d1c")
    private let systemBubbleColor = Color(hex: "383835")
    private let textColor = Color(hex: "F5F4EF")
    
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
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isFromUser {
                    Spacer(minLength: 32)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(isFromUser ? userBubbleColor : systemBubbleColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

// MARK: - Typing Indicator
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

// MARK: - Chat Input
struct ChatInput: View {
    @Binding var text: String
    let placeholder: String
    let isTyping: Bool
    let onSend: () -> Void
    
    // Use the exact color you specified
    private let backgroundColor = Color(hex: "3d3c3a")
    
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
                    .font(.system(size: 16))
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                    .padding(.vertical, 12)
                    .foregroundColor(Color(hex: "F5F4EF"))
                    .background(backgroundColor)
                
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
            .background(backgroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(backgroundColor)
        // Only rounded corners at the top
        .clipShape(
            RoundedCorners(topLeft: 16, topRight: 16, bottomLeft: 0, bottomRight: 0)
        )
    }
}

// MARK: - Custom shape for rounded corners
struct RoundedCorners: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.size.width
        let height = rect.size.height
        
        // Make sure we do not exceed the size of the rectangle
        let topRight = min(min(self.topRight, height/2), width/2)
        let topLeft = min(min(self.topLeft, height/2), width/2)
        let bottomLeft = min(min(self.bottomLeft, height/2), width/2)
        let bottomRight = min(min(self.bottomRight, height/2), width/2)
        
        // Top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                    radius: topLeft,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        // Top right corner
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
                    radius: topRight,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        // Bottom right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                    radius: bottomRight,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        // Bottom left corner
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                    radius: bottomLeft,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Button style
struct HitCraftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View extension for button style
extension View {
    func hitCraftStyle() -> some View {
        self.buttonStyle(HitCraftButtonStyle())
    }
}
