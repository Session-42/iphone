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
            
            let response: CreateChatResponse = try await apiClient.post(
                path: path,
                body: body
            )
            
            return response.threadId
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        } catch {
            print("Error creating chat: \(error.localizedDescription)")
            return "mock-thread-\(UUID().uuidString.prefix(8))"
        }
    }
    
    func sendMessage(content: MessageContent, threadId: String) async throws -> MessageResponse {
        do {
            let path = HCNetwork.Endpoints.chatMessages(threadId: threadId)
            let contentDict = content.toDictionary()
            let body: [String: Any] = ["content": contentDict]
            
            print("📍 Sending message to thread: \(threadId)")
            let response: MessageResponse = try await apiClient.post(
                path: path,
                body: body
            )
            return response
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        }
    }

    func sendTextMessage(text: String, threadId: String) async throws -> MessageResponse {
        return try await sendMessage(content: .text(content: text), threadId: threadId)
    }
    
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
    
    func deleteChat(threadId: String) async throws {
        do {
            let path = HCNetwork.Endpoints.deleteChat(threadId: threadId)
            print("📍 Deleting chat thread: \(threadId)")
            try await apiClient.delete(path: path)
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        } catch {
            print("Error deleting chat: \(error.localizedDescription)")
            throw error
        }
    }

    func getThreadPendingMessages(threadId: String) async throws -> [MessageData] {
        do {
            let path = HCNetwork.Endpoints.threadPendingMessages(threadId: threadId)
            
            let response: PendingMessagesResponse = try await apiClient.get(path: path)
            
            return response.messages
        } catch {
            print("Error fetching pending messages: \(error.localizedDescription)")
            throw error
        }
    }
}