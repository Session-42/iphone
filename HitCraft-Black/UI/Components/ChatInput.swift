// File: HitCraft-Black/UI/Components/ChatInput.swift

import SwiftUI

struct ChatInput: View {
    @Binding var text: String
    let placeholder: String
    let isTyping: Bool
    let onSend: () -> Void
    
    // Exact colors as specified
    private let backgroundColor = Color(hex: "3d3c3a")
    private let accentColor = Color(hex: "d6307a")
    
    // For text height adaptation
    @State private var textHeight: CGFloat = 40
    private let maxHeight: CGFloat = 120 // Approximately 5 lines
    
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
            // Input field with proper rounded top corners
            ZStack {
                // Background with rounded top corners
                RoundedCorners(topLeft: 16, topRight: 16, bottomLeft: 0, bottomRight: 0)
                    .fill(backgroundColor)
                
                // Input content
                HStack(alignment: .center, spacing: 8) {
                    // Text area with placeholder
                    ZStack(alignment: .topLeading) {
                        // Placeholder only when text is empty
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "999999"))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        // Text editor that grows with content
                        TextEditor(text: $text)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "F5F4EF"))
                            .frame(height: min(textHeight, maxHeight))
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .onChange(of: text) { _ in
                                // Calculate new height based on text content
                                let size = CGSize(width: UIScreen.main.bounds.width - 80, height: .infinity)
                                let estimatedHeight = text.boundingRect(
                                    with: size,
                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                    attributes: [.font: UIFont.systemFont(ofSize: 16)],
                                    context: nil
                                ).height
                                
                                // Set minimum height (40) and add padding
                                self.textHeight = max(40, estimatedHeight + 16)
                            }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Send button
                    Button(action: onSend) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(sendButtonColor)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.clear)
                                    .overlay(
                                        Circle()
                                            .stroke(text.isEmpty ? Color.gray.opacity(0.3) : accentColor, lineWidth: 1.5)
                                    )
                            )
                    }
                    .disabled(text.isEmpty || isTyping)
                    .hitCraftStyle()
                    .scaleEffect(isTyping ? 0.95 : 1.0)
                    .padding(.trailing, 16)
                    .padding(.bottom, 8)
                }
            }
            .frame(height: 60)
        }
        .background(backgroundColor)
    }
}

// Extension for text height calculation
extension String {
    func boundingRect(with size: CGSize, options: NSStringDrawingOptions, attributes: [NSAttributedString.Key: Any]?, context: NSStringDrawingContext?) -> CGRect {
        let nsString = self as NSString
        return nsString.boundingRect(with: size, options: options, attributes: attributes, context: context)
    }
}

// Custom shape for rounded corners (only at the top)
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
