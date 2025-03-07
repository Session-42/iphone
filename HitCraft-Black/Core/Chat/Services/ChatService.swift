// File: HitCraft-Black/Core/Chat/Services/ChatService.swift

import Foundation

@MainActor
final class ChatService {
    // MARK: - Properties
    private let apiClient: ApiClient
    var activeThreadId: String?
    
    static let shared = ChatService(apiClient: .shared)
    
    // MARK: - Initialization
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func createChat(artistId: String) async throws -> String {
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
        // Check if we have a mock thread ID and should return a mock response
        if let threadId = self.activeThreadId,
           (threadId.hasPrefix("mock-thread-") || threadId.hasPrefix("sample-thread-")) {
            return generateMockChatMessage(for: text)
        }
        
        // Get or create a real thread ID
        let threadId: String
        if let existingThreadId = self.activeThreadId, !existingThreadId.hasPrefix("sample-thread-") {
            threadId = existingThreadId
        } else {
            do {
                threadId = try await createChat(artistId: artistId)
            } catch {
                return ChatMessage(
                    content: "I'm having trouble connecting. Please check your internet connection and try again.",
                    sender: "assistant",
                    timestamp: Date()
                )
            }
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
            return try parseChatMessageResponse(response)
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
            return generateMockChatMessage(for: text)
        }
    }
    
    func getChatHistory(artistId: String) async throws -> [ChatMessage] {
        // If we have a mock thread ID, return mock messages
        if let threadId = self.activeThreadId,
           (threadId.hasPrefix("mock-thread-") || threadId.hasPrefix("sample-thread-")) {
            return generateMockChatHistory()
        }
        
        // For now, return an empty array as the history endpoint may not be implemented
        // This can be expanded once the API supports chat history retrieval
        return []
    }
    
    // MARK: - Private Helper Methods
    private func parseChatMessageResponse(_ response: [String: Any]) throws -> ChatMessage {
        // First try to parse message from the expected structure
        if let messageData = response["message"] as? [String: Any] {
            // Try to handle both array and direct content formats
            if let contentArray = messageData["content"] as? [[String: Any]], let firstContent = contentArray.first, let messageText = firstContent["text"] as? String {
                let timestamp = messageData["timestamp"] as? String ?? ISO8601DateFormatter().string(from: Date())
                let role = messageData["role"] as? String ?? "assistant"
                
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
            // Try alternative format where content might be a direct string
            else if let directContent = messageData["content"] as? String {
                let timestamp = messageData["timestamp"] as? String ?? ISO8601DateFormatter().string(from: Date())
                let role = messageData["role"] as? String ?? "assistant"
                
                // Parse ISO8601 date
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let date = formatter.date(from: timestamp) ?? Date()
                
                return ChatMessage(
                    content: directContent,
                    sender: role,
                    timestamp: date
                )
            }
        }
        
        // Fallback method if the expected structure isn't found
        // This is just to ensure we can handle unexpected response formats
        if let messageData = response["data"] as? [String: Any],
           let messageObj = messageData["message"] as? [String: Any],
           let text = messageObj["content"] as? String {
            return ChatMessage(
                content: text,
                sender: messageObj["role"] as? String ?? "assistant",
                timestamp: Date()
            )
        }
        
        throw HCNetwork.Error.decodingError(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse message response"]))
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
            
            <iframe width="560" height="315" src="https://www.youtube.com/embed/fJ9rUzIMcZQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            
            What aspects of this song inspire you for your own music?
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
