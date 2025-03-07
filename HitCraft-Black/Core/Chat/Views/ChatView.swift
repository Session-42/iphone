import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @State private var error: Error?
    @State private var showError = false
    
    let artistId: String
    private let chatService = ChatService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Messages
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    if isTyping {
                        TypingIndicator()
                    }
                }
                .padding()
            }
            
            // Message Input
            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
                .disabled(messageText.isEmpty || isTyping)
            }
            .padding()
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(error?.localizedDescription ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = ChatMessage(content: messageText, sender: "user")
        messages.append(userMessage)
        
        let sentMessage = messageText
        messageText = ""
        isTyping = true
        
        Task {
            do {
                let responseMessage = try await chatService.sendMessage(
                    text: sentMessage,
                    artistId: artistId
                )
                
                await MainActor.run {
                    isTyping = false
                    messages.append(responseMessage)
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    showError = true
                    isTyping = false
                }
            }
        }
    }
}

// Supporting Views
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            Text(message.content)
                .padding()
                .background(message.isFromUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: message.isFromUser ? .trailing : .leading)
        }
    }
}

struct TypingIndicator: View {
    var body: some View {
        Text("Typing...")
            .foregroundColor(.gray)
            .italic()
    }
}
