import Foundation
import SwiftUI
import Combine

// This class manages chat state at the application level
// so it persists when switching between tabs
@MainActor
class ChatPersistenceManager: ObservableObject {
    static let shared = ChatPersistenceManager()
    
    @Published var messages: [ChatMessage] = []
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
            // Chat already initialized
            return
        }
        
        do {
            // Clear previous messages
            messages = []
            
            // Create chat thread and save ID
            self.threadId = try await chatService.createChat(artistId: artistId)
            
            // Create a welcome message
            let welcomeMessage = ChatMessage(
                content: "Welcome! I'm HitCraft, your AI music assistant. How can I help with your music today?",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
            )
            
            // Update state
            self.messages = [welcomeMessage]
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
        // Create user message
        let userMessage = ChatMessage(
            content: text,
            sender: "user"
        )
        
        // Add user message
        messages.append(userMessage)
        
        // Set scroll anchor and trigger scroll
        scrollAnchor = UnitPoint(x: 0.5, y: 0.88)
        triggerScrollTo(id: userMessage.id.uuidString, anchor: scrollAnchor)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isTyping = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.triggerScrollTo(id: userMessage.id.uuidString, anchor: self.scrollAnchor)
            }
        }
        
        do {
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // Check for valid threadId
            guard let threadId = self.threadId else {
                throw HCNetwork.Error.requestFailed("No active chat thread")
            }
            
            // Send message to API with unwrapped threadId
            let responseMessage = try await chatService.sendMessage(
                text: text,
                threadId: threadId
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isTyping = false
                self.messages.append(responseMessage)
                
                let isLongResponse = responseMessage.content.count > 300
                let anchor: UnitPoint = isLongResponse ? .top : .bottom
                self.triggerScrollTo(id: responseMessage.id.uuidString, anchor: anchor)
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
            triggerScrollTo(id: lastMessage.id.uuidString, anchor: .bottom)
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
        
                    // Convert API messages to ChatMessage objects
                    messages = response.messages.map { messageData in
                        let content = messageData.content
                            .filter { $0.type == "text" }
                            .map { $0.text }
                            .joined(separator: "\n")
                        let type = messageData.content.first?.format == "markdown" ? "markdown" : "text"
        
                        // Parse timestamp
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        let date = formatter.date(from: messageData.timestamp) ?? Date()
        
                        return ChatMessage(
                            content: content,
                            sender: messageData.role,
                            type: type,
                            timestamp: date
                        )
                    }
        
                    print("Messages loaded: \(messages.count)")
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
    }
