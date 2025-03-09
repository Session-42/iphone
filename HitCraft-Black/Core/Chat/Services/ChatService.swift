// File: HitCraft-Black/Core/Chat/Services/ChatService.swift

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
        
        // Check if the response contains a "format" field - this would indicate if it's markdown
        let format = firstContent["format"] as? String ?? "text"
        let type = format == "markdown" ? "markdown" : "text"
        
        return ChatMessage(
            content: messageText,
            sender: role,
            type: type,
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
    
    // MARK: - Chat History Methods
    // Get chat thread history
    func getChatThreads(artistId: String) async throws -> [ChatItem] {
        // This is a mock implementation - in a real app you would call your API
        let mockThreads = [
            ChatItem(
                title: "Need help with my 2nd verse lyrics",
                details: ChatDetails(
                    pluginName: "Songwriting",
                    year: "2025",
                    presetLink: "https://hitcraft.ai/presets/lyrics"
                ),
                threadId: "sample-thread-1",
                date: Date().addingTimeInterval(-86400), // 1 day ago
                previewMessage: "I'm working on a song and stuck on the second verse...",
                messageCount: 12
            ),
            ChatItem(
                title: "I need some help with good presets for kick drum sound",
                details: ChatDetails(
                    pluginName: "12/07/92",
                    year: "2025",
                    presetLink: "https://hitcraft.ai/presets/kick"
                ),
                threadId: "sample-thread-2",
                date: Date().addingTimeInterval(-259200), // 3 days ago
                previewMessage: "I'm looking for that punchy club kick sound...",
                messageCount: 8
            ),
            ChatItem(
                title: "Catchy drop ideas for EDM track",
                details: ChatDetails(
                    pluginName: "EDM Production",
                    year: "2025",
                    presetLink: "https://hitcraft.ai/presets/edm"
                ),
                threadId: "sample-thread-3",
                date: Date().addingTimeInterval(-345600), // 4 days ago
                previewMessage: "I want something that will really make the crowd go wild...",
                messageCount: 15
            ),
            ChatItem(
                title: "Pop ballad production tips",
                details: ChatDetails(
                    pluginName: "Pop Ballad",
                    year: "2025",
                    presetLink: "https://hitcraft.ai/presets/ballad"
                ),
                threadId: "sample-thread-4",
                date: Date().addingTimeInterval(-604800), // 1 week ago
                previewMessage: "I'm trying to create something like Adele meets The Weeknd...",
                messageCount: 20
            ),
            ChatItem(
                title: "Recommend the right tempo for my song",
                details: ChatDetails(
                    pluginName: "Tempo Guide",
                    year: "2025",
                    presetLink: "https://hitcraft.ai/presets/tempo"
                ),
                threadId: "sample-thread-5",
                date: Date().addingTimeInterval(-1209600), // 2 weeks ago
                previewMessage: "I'm not sure if this should be 90 or 110 bpm...",
                messageCount: 5
            )
        ]
        
        return mockThreads
    }
    
    // Get messages for a specific thread
    func getChatThreadMessages(threadId: String) async throws -> [ChatMessage] {
        // Find mock thread by ID
        let mockThreads = try await getChatThreads(artistId: "default")
        guard let thread = mockThreads.first(where: { $0.threadId == threadId }) else {
            throw HCNetwork.Error.requestFailed("Thread not found")
        }
        
        // Generate some messages based on the thread title
        return [
            ChatMessage(
                content: "I was working on \(thread.title)",
                sender: "user",
                timestamp: Date().addingTimeInterval(-7200) // 2 hours ago
            ),
            ChatMessage(
                content: "I'll help you with \(thread.title). Let me know what specific aspects you need assistance with.",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-7150) // Just after
            ),
            ChatMessage(
                content: "Can you provide some examples for \(thread.title)?",
                sender: "user",
                timestamp: Date().addingTimeInterval(-7100)
            ),
            ChatMessage(
                content: "Sure, here are some ideas for \(thread.title)...",
                sender: "assistant",
                timestamp: Date().addingTimeInterval(-7050)
            )
        ]
    }
}
