// File: HitCraft-Black/Services/ChatPersistenceManager.swift

import Foundation
import SwiftUI
import Combine

// This class will manage chat state at the application level
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
}
