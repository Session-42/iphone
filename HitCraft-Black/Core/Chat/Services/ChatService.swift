import Foundation
@MainActor
final class ChatService {
    private let apiClient: ApiClient
    static let shared = ChatService(apiClient: .shared)
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func createChat(artistId: String) async throws -> String {
        do {
            let path = HCNetwork.Endpoints.createChat()
            let body: [String: Any] = ["artistId": artistId]
            print("📍 Creating chat for artist ID: \(artistId)")
            
            let response: CreateChatResponse = try await apiClient.post(
                path: path,
                body: body
            )
            
            print("Created thread: \(response.threadId)")
            return response.threadId
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        } catch {
            print("Error creating chat: \(error.localizedDescription)")
            return "mock-thread-\(UUID().uuidString.prefix(8))"
        }
    }
    
    func sendMessage(text: String, threadId: String) async throws -> ChatMessage {
        do {
            let path = HCNetwork.Endpoints.chatMessages(threadId: threadId)
            let fragment: [String: Any] = [
                "text": text,
                "type": "text"
            ]
            let body: [String: Any] = ["content": fragment]
            
            print("📍 Sending message to thread: \(threadId)")
            
            let response: MessageResponse = try await apiClient.post(
                path: path,
                body: body
            )
            
            return try parseChatMessageResponse(response)
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            return ChatMessage(
                content: "Your session has expired. Please sign in again.",
                sender: "assistant",
                timestamp: Date()
            )
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            return ChatMessage(
                content: "Error",
                sender: "assistant",
                timestamp: Date()
            )
        }
    }
    
    /// List chat threads with optional amount parameter
    func listChats(amount: Int = 3) async throws -> ThreadsResponse {
        do {
            let path = HCNetwork.Endpoints.listChats(amount: amount)
            print("📍 Listing \(amount) chats")
            let response: ThreadsResponse = try await apiClient.get(path: path)
            return response
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        } catch {
            print("Error listing chats: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// List messages for a specific chat thread
    func listMessages(threadId: String) async throws -> MessagesResponse {
        do {
            let path = HCNetwork.Endpoints.chatMessages(threadId: threadId)
            print("📍 Listing messages for thread: \(threadId)")
            let response: MessagesResponse = try await apiClient.get(path: path)
            return response
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        } catch {
            print("Error listing messages: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func parseChatMessageResponse(_ response: MessageResponse) throws -> ChatMessage {
        let messageData = response.message
        let content = messageData.content.first
        
        guard let messageText = content?.text else {
            throw HCNetwork.Error.decodingError(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse message response"]))
        }
        
        // Parse ISO8601 date
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: messageData.timestamp) ?? Date()
        
        // Check if the response contains a format field
        let type = content?.format == "markdown" ? "markdown" : "text"
        
        return ChatMessage(
            content: messageText,
            sender: messageData.role,
            type: type,
            timestamp: date
        )
    }
}