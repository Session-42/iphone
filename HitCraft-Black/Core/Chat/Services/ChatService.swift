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
    
    func sendMessage(text: String, threadId: String) async throws -> MessageResponse {
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
            
            return response
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            // Create a mock MessageResponse for unauthorized error
            return MessageResponse(
                message: MessageData(
                    content: [MessageContent(
                        text: "Your session has expired. Please sign in again.",
                        type: "text",
                        format: nil
                    )],
                    timestamp: Date().ISO8601Format(),
                    role: "assistant"
                )
            )
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            // Create a mock MessageResponse for general error
            return MessageResponse(
                message: MessageData(
                    content: [MessageContent(
                        text: "Error sending message",
                        type: "text",
                        format: nil
                    )],
                    timestamp: Date().ISO8601Format(),
                    role: "assistant"
                )
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
}