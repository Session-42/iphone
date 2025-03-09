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
        isTyping = true
        
        do {
            // Add a small delay for natural feel
            try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
            
            // Send message to API
            let responseMessage = try await chatService.sendMessage(
                text: text,
                artistId: artistId
            )
            
            // Hide typing indicator
            isTyping = false
            
            // Short pause before showing the response
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            // Add the response message
            messages.append(responseMessage)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            isTyping = false
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
