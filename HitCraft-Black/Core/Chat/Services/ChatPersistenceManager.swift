import Foundation
import SwiftUI
import Combine

// This class manages chat state at the application level
// so it persists when switching between tabs
@MainActor
class ChatPersistenceManager: ObservableObject {
    static let shared = ChatPersistenceManager()
    
    @Published private(set) var messages: [MessageData] = []
    @Published var isInitialized: Bool = false
    @Published var hasActiveChat: Bool = false
    @Published var isTyping: Bool = false
    @Published var threadId: String? = nil
    
    @Published var scrollTarget: String? = nil  // ID to scroll to
    @Published var scrollAnchor: UnitPoint = .bottom // Anchor point for scroll
    @Published var scrollTrigger: UUID = UUID() // Change this to force a scroll
    
    private let chatService = ChatService.shared
    
    private init() {}
    
    func initializeChat(artistId: String) async {
        if isInitialized && hasActiveChat && !messages.isEmpty {
            return
        }
        
        do {
            // Clear previous messages
            messages = []
            
            self.threadId = try await chatService.createChat(artistId: artistId)
            self.isInitialized = true
            self.hasActiveChat = true
            
            // Trigger initial scroll to bottom
            triggerScrollToBottom()
        } catch {
            print("Error initializing chat: \(error.localizedDescription)")
            // Set as initialized anyway to prevent continuous retries
            self.isInitialized = true
        }
    }
    
    func sendMessage(text: String) async {
        guard !text.isEmpty else { return }
        // If no threadId exists, initialize the chat first
        if self.threadId == nil {
            await initializeChat(artistId: ArtistProfile.sample.id)
        }

        let userMessageResponse = MessageData(
                content: [.text(content: text)],
                timestamp: Date().ISO8601Format(),
                role: "user",
                id: UUID().uuidString
            )
        
        // Add user message
        appendMessage(userMessageResponse)
        
        // Set scroll anchor and trigger scroll
        scrollAnchor = UnitPoint(x: 0.5, y: 0.88)
        triggerScrollTo(id: UUID().uuidString, anchor: scrollAnchor)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isTyping = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.triggerScrollTo(id: UUID().uuidString, anchor: self.scrollAnchor)
            }
        }
        
        do {
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // Check for valid threadId
            guard let threadId = self.threadId else {
                throw HCNetwork.Error.requestFailed("No active chat thread")
            }
            
            // Send message to API with unwrapped threadId
            let responseMessage = try await chatService.sendTextMessage(
                text: text,
                threadId: threadId
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isTyping = false
                self.messages.append(responseMessage.message)
                
                let isLongResponse = responseMessage.message.content.count > 300
                let anchor: UnitPoint = isLongResponse ? .top : .bottom
                self.triggerScrollTo(id: UUID().uuidString, anchor: anchor)
            }
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            isTyping = false
        }
    }
    
    // MARK: - Scroll Control Methods
    
    // Trigger a scroll to a specific ID
    func triggerScrollTo(id: String, anchor: UnitPoint) {
        scrollTarget = id
        scrollAnchor = anchor
        scrollTrigger = UUID() // Change this to force observers to react
        
        // Double-check scroll with delay to ensure it takes effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            // Only update the trigger to avoid changing the target
            self.scrollTrigger = UUID()
        }
        
        // Triple-check with longer delay for reliable scrolling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            self.scrollTrigger = UUID()
        }
    }
    
    // Trigger scroll to bottom
    func triggerScrollToBottom() {
        if let lastMessage = messages.last {
            triggerScrollTo(id: UUID().uuidString, anchor: .bottom)
        } else {
            // Scroll to bottom spacer if no messages
            scrollTarget = "bottomSpacer"
            scrollAnchor = .bottom
            scrollTrigger = UUID()
        }
    }
    
    // Trigger scroll to typing indicator
    func triggerScrollToTypingIndicator() {
        scrollTarget = "typingIndicator"
        scrollAnchor = .bottom
        scrollTrigger = UUID()
        
        // Double-check scroll with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            // Only update the trigger to avoid changing the target
            self.scrollTrigger = UUID()
        }
    }
    
    // Clear the chat to start a new one
    func clearChat() {
        messages = []
        isInitialized = false
        hasActiveChat = false
        threadId = nil
    }
    
    func prepareToLoadChatThread(threadId: String) {
            // Clear any existing messages
            messages = []
        
            // Set the active thread ID
            self.threadId = threadId
        
            // Show loading state briefly
            isTyping = true
        
            Task {
                do {
                    let response = try await ChatService.shared.listMessages(threadId: threadId)
                    messages = response.messages
        
                    isTyping = false
                    isInitialized = true
                    hasActiveChat = true
        
                    // Scroll to the latest message
                    triggerScrollToBottom()
        
                    // Post notification that messages are loaded
                    NotificationCenter.default.post(name: NSNotification.Name("ChatThreadLoaded"), object: nil)
        
                } catch {
                    print("Error loading messages: \(error)")
                    isTyping = false
                }
            }
        }

    func appendMessage(_ message: MessageData) {
        // Only append if the message doesn't already exist
        if !messages.contains(where: { $0.id == message.id }) {
            messages.append(message)
            triggerScrollToBottom()
        }
    }
}
