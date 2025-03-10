// File: HitCraft-Black/Services/ChatPersistenceManager.swift

import Foundation
import SwiftUI
import Combine

// This class manages chat state at the application level
// so it persists when switching between tabs
@MainActor
class ChatPersistenceManager: ObservableObject {
    static let shared = ChatPersistenceManager()
    
    // Published variables that can be observed by views
    @Published var messages: [ChatMessage] = []
    @Published var isInitialized: Bool = false
    @Published var hasActiveChat: Bool = false
    @Published var isTyping: Bool = false
    
    // NEW: Scroll control variables
    @Published var scrollTarget: String? = nil  // ID to scroll to
    @Published var scrollAnchor: UnitPoint = .bottom // Anchor point for scroll
    @Published var scrollTrigger: UUID = UUID() // Change this to force a scroll
    
    // Chat service instance
    private let chatService = ChatService.shared
    
    // Private initializer for singleton
    private init() {}
    
    // Initialize a new chat
    func initializeChat(artistId: String) async {
        if isInitialized && hasActiveChat && !messages.isEmpty {
            // Chat already initialized
            return
        }
        
        do {
            // Clear previous messages
            messages = []
            
            // Create a welcome message
            let welcomeMessage = ChatMessage(
                content: "Welcome! I'm HitCraft, your AI music assistant. How can I help with your music today?",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
            )
            
            // Create a new chat with initial message
            let message = try await chatService.sendMessage(
                text: "Hello, I'd like to create music",
                artistId: artistId
            )
            
            // Update state
            self.messages = [welcomeMessage, message]
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
    
    // Send a message and update state
    func sendMessage(text: String, artistId: String) async {
        guard !text.isEmpty else { return }
        
        // Create user message
        let userMessage = ChatMessage(
            content: text,
            sender: "user"
        )
        
        // Add user message
        messages.append(userMessage)
        
        // First, create a custom spacer height to push the message up higher in the view
        // to leave room for the typing indicator - using a much higher position now
        // Create a custom anchor to position the message with just a little padding
        scrollAnchor = UnitPoint(x: 0.5, y: 0.88) // 0.88 gives a small amount of space
        
        // Immediately trigger scroll to show the user message with extra space below
        triggerScrollTo(id: userMessage.id.uuidString, anchor: scrollAnchor)
        
        // IMPORTANT: Show typing indicator ONLY AFTER the first scroll completes
        // This is crucial to prevent the typing indicator from appearing too soon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Now set typing state
            self.isTyping = true
            
            // After typing indicator appears, make sure it's visible and the message remains visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                
                // Use the same high anchor point to keep message visible with typing indicator
                self.triggerScrollTo(id: userMessage.id.uuidString, anchor: self.scrollAnchor)
            }
        }
        
        do {
            // Add a small delay for natural feel
            try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
            
            // Send message to API
            let responseMessage = try await chatService.sendMessage(
                text: text,
                artistId: artistId
            )
            
            // Short pause before hiding typing indicator
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Hide typing indicator
                self.isTyping = false
                
                // IMPORTANT: Instead of showing response after delay, add it immediately
                // This prevents the unwanted scrolling motion between typing and response
                self.messages.append(responseMessage)
                
                // Determine if it's a long message to adjust scroll behavior
                let isLongResponse = responseMessage.content.count > 300
                let anchor: UnitPoint = isLongResponse ? .top : .bottom
                
                // Trigger scroll to the new message with proper anchor
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
        chatService.clearChatData()
    }
    
    // Method to prepare loading a specific chat thread
    func prepareToLoadChatThread(threadId: String, title: String) {
        // Clear any existing messages
        messages = []
        isInitialized = false
        hasActiveChat = false
        
        // Set the active thread ID
        ChatService.shared.activeThreadId = threadId
        
        // Show loading state briefly
        isTyping = true
        
        // Load chat thread with a simulated delay for better UX
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
            
            // Generate continuation messages
            let historyMessages = generateContinuationMessages(title: title)
            messages = historyMessages
            
            isTyping = false
            isInitialized = true
            hasActiveChat = true
            
            // Scroll to the latest message
            triggerScrollToBottom()
            
            // Post notification that messages are loaded
            NotificationCenter.default.post(name: NSNotification.Name("ChatThreadLoaded"), object: nil)
        }
    }
    
    // Generate continuation messages for a resumed chat
    private func generateContinuationMessages(title: String) -> [ChatMessage] {
        // Create a welcome back message tailored to the chat topic
        let welcomeBack = ChatMessage(
            content: "Welcome back to your conversation about \"\(title)\". How can I help you further today?",
            sender: "assistant",
            timestamp: Date()
        )
        
        // Create a small sample of previous exchange
        return [
            ChatMessage(
                content: "I was working on \(title)",
                sender: "user",
                timestamp: Date().addingTimeInterval(-7200) // 2 hours ago
            ),
            ChatMessage(
                content: "I'll help you with \(title). Let me know what specific aspects you need assistance with.",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-7150) // Just after
            ),
            welcomeBack
        ]
    }
    
    // Load most recent conversations for display in Home view
    func loadRecentChats(count: Int = 3) async -> [ChatItem] {
        do {
            // Get all chat threads
            let allThreads = try await chatService.getChatThreads(artistId: "67618ad67dc13643acff6a25")
            
            // Sort by date and take the most recent ones
            let recentThreads = allThreads
                .sorted { $0.date > $1.date }
                .prefix(count)
            
            return Array(recentThreads)
        } catch {
            print("Error loading recent chats: \(error.localizedDescription)")
            return []
        }
    }
    
    // Save current chat as a new thread
    func saveCurrentChatAsThread(title: String, artistId: String) async -> Bool {
        guard !messages.isEmpty else { return false }
        
        // In a real app, you would call an API to save the chat
        // For now, we'll just pretend it worked
        return true
    }
    
    // Delete a chat thread
    func deleteThread(threadId: String) async -> Bool {
        // In a real app, you would call an API to delete the thread
        // For now, we'll just pretend it worked
        return true
    }
}
