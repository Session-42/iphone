import SwiftUI

struct ChatInput: View {
    @Binding var text: String
    let placeholder: String
    let isTyping: Bool
    let onSend: () -> Void
    
    // Track input height to allow expansion
    @State private var textViewHeight: CGFloat = 36
    private let maxHeight: CGFloat = 120 // Maximum height before scrolling
    
    // Button color
    private var sendButtonColor: Color {
        if text.isEmpty || isTyping {
            return Color.gray.opacity(0.6)
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // Custom text view that looks solid but can expand
                ZStack(alignment: .leading) {
                    // Background for the text field
                    RoundedRectangle(cornerRadius: 20)
                        .fill(HitCraftColors.chatInputBackground)
                    
                    // Placeholder text with proper alignment
                    if text.isEmpty {
                        Text(placeholder)
                            .font(HitCraftFonts.body()) // Using Poppins font from HitCraftFonts
                            .foregroundColor(HitCraftColors.secondaryText)
                            .padding(.leading, 15)
                            .padding(.vertical, 8)
                    }
                    
                    // The actual text editor for expandable input
                    UITextViewWrapper(text: $text, height: $textViewHeight, maxHeight: maxHeight)
                        .frame(height: min(textViewHeight, maxHeight))
                        .padding(.vertical, 2)
                }
                .frame(height: min(textViewHeight + 16, maxHeight + 16))
                .padding(.leading, 0) // No extra padding here
                .padding(.trailing, 0) // No extra padding here
                
                // Send button with gradient border when active
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(sendButtonColor)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                        )
                        .overlay(
                            Group {
                                if text.isEmpty || isTyping {
                                    Circle()
                                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                                } else {
                                    Circle()
                                        .strokeBorder(HitCraftColors.primaryGradient, lineWidth: 2)
                                }
                            }
                        )
                }
                .disabled(text.isEmpty || isTyping)
                .hitCraftStyle()
                .scaleEffect(isTyping ? 0.95 : 1.0)
            }
            .padding(.horizontal, 15) // Only padding at this level
            .padding(.vertical, 10)
            .background(HitCraftColors.chatInputBackground)
        }
        .background(HitCraftColors.chatInputBackground)
        .clipShape(
            RoundedCorners(topLeft: 16, topRight: 16, bottomLeft: 0, bottomRight: 0)
        )
        .padding(.top, -16)
        .zIndex(1)
    }
}

// UITextView wrapper to get auto-expanding behavior while maintaining styling
struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    let maxHeight: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        
        // Use Poppins font to match HitCraftFonts.body()
        if let poppinsFont = UIFont(name: "Poppins-Regular", size: 16) {
            textView.font = poppinsFont
        } else {
            // Fallback to system font if Poppins is not available
            textView.font = UIFont.systemFont(ofSize: 16)
        }
        
        // Set exact left inset to 15px with no additional padding
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        textView.textContainer.lineFragmentPadding = 0 // Remove extra padding
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Center the cursor position vertically and use Poppins font
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        
        // Use Poppins font for typing attributes
        if let poppinsFont = UIFont(name: "Poppins-Regular", size: 16) {
            textView.typingAttributes = [
                .paragraphStyle: paragraphStyle,
                .font: poppinsFont,
                .foregroundColor: UIColor.white
            ]
        } else {
            textView.typingAttributes = [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
            recalculateHeight(view: uiView)
        }
    }
    
    private func recalculateHeight(view: UITextView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(newSize.height, maxHeight)
        if height != newHeight {
            DispatchQueue.main.async {
                self.height = newHeight
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        
        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.recalculateHeight(view: textView)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        ChatInput(
            text: .constant(""),
            placeholder: "Type your message...",
            isTyping: false,
            onSend: {}
        )
    }
    .background(HitCraftColors.chatBackground)
}
