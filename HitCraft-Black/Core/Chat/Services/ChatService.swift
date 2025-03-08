// File: HitCraft-Black/Services/ChatService.swift

import Foundation

@MainActor
final class ChatService {
    // MARK: - Properties
    private let apiClient: ApiClient
    var activeThreadId: String?
    private var messageCache: [String: [ChatMessage]] = [:] // Cache to store messages by threadId
    
    static let shared = ChatService(apiClient: .shared)
    
    // MARK: - Initialization
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func createChat(artistId: String) async throws -> String {
        // If we already have an active thread ID, return it
        if let activeThreadId = self.activeThreadId,
           !activeThreadId.hasPrefix("mock-thread-") ||
            !activeThreadId.hasPrefix("sample-thread-") {
            return activeThreadId
        }
        
        do {
            // Create a chat thread
            let path = HCNetwork.Environment.Endpoint.createChat()
            
            let body: [String: Any] = [
                "artistId": artistId
            ]
            
            print("📍 Creating chat for artist ID: \(artistId)")
            
            let response: [String: Any] = try await apiClient.post(
                path: path,
                body: body
            )
            
            guard let threadId = response["threadId"] as? String else {
                throw HCNetwork.Error.serverError(code: 400, message: "Failed to create chat thread")
            }
            
            print("Created thread: \(threadId)")
            self.activeThreadId = threadId
            return threadId
        } catch HCNetwork.Error.unauthorized {
            // For unauthorized error, trigger logout
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        } catch {
            print("Error creating chat: \(error.localizedDescription)")
            
            // For development/fallback, use a mock thread ID
            let mockThreadId = "mock-thread-\(UUID().uuidString.prefix(8))"
            self.activeThreadId = mockThreadId
            return mockThreadId
        }
    }
    
    func sendMessage(text: String, artistId: String) async throws -> ChatMessage {
        // Check if we have a thread ID first
        let threadId: String
        if let existingThreadId = self.activeThreadId {
            threadId = existingThreadId
        } else {
            // Create a new thread if we don't have one
            threadId = try await createChat(artistId: artistId)
        }
        
        // Check if we have a mock thread ID and should return a mock response
        if threadId.hasPrefix("mock-thread-") || threadId.hasPrefix("sample-thread-") {
            let mockResponse = generateMockChatMessage(for: text)
            
            // Cache the message
            if messageCache[threadId] == nil {
                messageCache[threadId] = []
            }
            messageCache[threadId]?.append(mockResponse)
            
            return mockResponse
        }
        
        do {
            // Send message to the thread
            let path = HCNetwork.Environment.Endpoint.chatMessages(threadId: threadId)
            
            let fragment: [String: Any] = [
                "text": text,
                "type": "text"
            ]
            
            let body: [String: Any] = [
                "content": fragment
            ]
            
            print("📍 Sending message to thread: \(threadId)")
            
            let response: [String: Any] = try await apiClient.post(
                path: path,
                body: body
            )
            
            // Parse the response
            let chatMessage = try parseChatMessageResponse(response)
            
            // Cache the message
            if messageCache[threadId] == nil {
                messageCache[threadId] = []
            }
            messageCache[threadId]?.append(chatMessage)
            
            return chatMessage
        } catch HCNetwork.Error.unauthorized {
            // For unauthorized errors, trigger logout
            await HCAuthService.shared.logout()
            
            return ChatMessage(
                content: "Your session has expired. Please sign in again.",
                sender: "assistant",
                timestamp: Date()
            )
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            
            // Return a mock response for development/testing
            let mockResponse = generateMockChatMessage(for: text)
            
            // Cache the message
            if messageCache[threadId] == nil {
                messageCache[threadId] = []
            }
            messageCache[threadId]?.append(mockResponse)
            
            return mockResponse
        }
    }
    
    func getChatHistory(artistId: String) async throws -> [ChatMessage] {
        // If we have cached messages for the current thread, return them
        if let threadId = self.activeThreadId, let messages = messageCache[threadId], !messages.isEmpty {
            return messages
        }
        
        // If we have a mock thread ID, return mock messages
        if let threadId = self.activeThreadId,
           (threadId.hasPrefix("mock-thread-") || threadId.hasPrefix("sample-thread-")) {
            return generateMockChatHistory()
        }
        
        // For now, return an empty array as the history endpoint may not be implemented
        // This can be expanded once the API supports chat history retrieval
        return []
    }
    
    // Clear all chat data when starting a new chat
    func clearChatData() {
        activeThreadId = nil
        // Don't clear cache entirely, just make sure we don't use it for the next chat
    }
    
    // MARK: - Private Helper Methods
    private func parseChatMessageResponse(_ response: [String: Any]) throws -> ChatMessage {
        guard
            let messageData = response["message"] as? [String: Any],
            let contentArray = messageData["content"] as? [[String: Any]],
            let firstContent = contentArray.first,
            let messageText = firstContent["text"] as? String,
            let timestamp = messageData["timestamp"] as? String,
            let role = messageData["role"] as? String
        else {
            throw HCNetwork.Error.decodingError(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse message response"]))
        }
        
        // Parse ISO8601 date
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let date = formatter.date(from: timestamp) ?? Date()
        
        return ChatMessage(
            content: messageText,
            sender: role,
            timestamp: date
        )
    }
    
    private func generateMockChatMessage(for message: String) -> ChatMessage {
        return ChatMessage(
            content: generateMockResponse(to: message),
            sender: "assistant",
            timestamp: Date()
        )
    }
    
    private func generateMockChatHistory() -> [ChatMessage] {
        return [
            ChatMessage(
                content: "Welcome back to our conversation! How can I help you today?",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
            ),
            ChatMessage(
                content: "I was working on a song earlier",
                sender: "user",
                timestamp: Date().addingTimeInterval(-3500) // 58 minutes ago
            ),
            ChatMessage(
                content: "Great! I remember we were discussing your song. Would you like to continue where we left off?",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-3450) // 57 minutes ago
            )
        ]
    }
    
    private func generateMockResponse(to message: String) -> String {
        // Add YouTube embed example if asked about a song
        if message.lowercased().contains("song") &&
            (message.lowercased().contains("greatest") || message.lowercased().contains("best") ||
             message.lowercased().contains("youtube") || message.lowercased().contains("video")) {
            
            return """
            Based on many critics and polls, one of the greatest songs of all time is "Bohemian Rhapsody" by Queen. This epic 1975 masterpiece combined rock, opera, and ballad elements in a revolutionary way.
            
            <iframe src="https://www.youtube.com/embed/fJ9rUzIMcZQ" allow="autoplay; encrypted-media" allowfullscreen style="border-radius: 12px; width: 100%; height: 300px;"></iframe>
            
            What aspects of this song inspire you for your own music?
            """
        }
        
        // For other music-related keywords, you can add more embedded videos
        if message.lowercased().contains("sad") || message.lowercased().contains("emotional") {
            return """
            If you're looking for emotional music, Johnny Cash's cover of "Hurt" is incredibly powerful and moving.
            
            <iframe src="https://www.youtube.com/embed/8AHCfZTRGiI" allow="autoplay; encrypted-media" allowfullscreen style="border-radius: 12px; width: 100%; height: 300px;"></iframe>
            
            The raw emotion in his voice and the stark visuals of the music video make this one of the most powerful musical performances ever recorded.
            """
        }
        
        if message.lowercased().contains("classic") || message.lowercased().contains("rock") {
            return """
            Classic rock has some timeless pieces. Led Zeppelin's "Stairway to Heaven" is often considered one of the greatest rock songs ever written.
            
            <iframe src="https://www.youtube.com/embed/QkF3oxziUI4" allow="autoplay; encrypted-media" allowfullscreen style="border-radius: 12px; width: 100%; height: 300px;"></iframe>
            
            The composition gradually builds from a gentle acoustic beginning to an epic guitar solo finale.
            """
        }
        
        // Simple responses for common music questions
        if message.lowercased().contains("chord") || message.lowercased().contains("progression") {
            return "For a pop song, try a classic I-V-vi-IV progression. In the key of C major, that would be C-G-Am-F. This progression is used in countless hit songs!"
        } else if message.lowercased().contains("lyric") || message.lowercased().contains("verse") {
            return "When writing lyrics, try focusing on a specific emotion or experience. Start with a strong hook that captures the essence of what you want to express, then build verses around that central theme."
        } else if message.lowercased().contains("beat") || message.lowercased().contains("drum") {
            return "For a solid pop beat, start with a four-on-the-floor kick pattern, add snares on beats 2 and 4, and use hi-hats to create rhythm and movement. Try adding subtle variations every 4 or 8 bars to keep it interesting."
        } else if message.lowercased().contains("mix") || message.lowercased().contains("master") {
            return "When mixing, focus on creating space for each element. Start with balancing levels, then work on panning, EQ, compression, and finally add effects like reverb and delay. Remember that less is often more!"
        } else {
            return "I'd love to help with your music project! Could you tell me more about what you're working on or what specific aspect you need assistance with?"
        }
    }
}
