import Foundation
import DescopeKit

@MainActor
final class ChatService {
    static let shared = ChatService()
    private let apiClient: ApiClient
    
    private init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }
    
    func sendMessage(text: String, artistId: String) async throws -> ChatMessage {
        let messageRequest: [String: Any] = [
            "artistId": artistId,
            "message": [
                "content": text,
                "type": "text",
                "sender": "user",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ] as [String: Any]
        ]
        
        do {
            let response: ChatResponse = try await apiClient.post(
                path: HCEnvironment.Endpoint.chatMessages(threadId: "current_thread"),
                body: messageRequest
            )
            
            guard let message = response.data?.message else {
                throw ApiError.decodingError(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse message"]))
            }
            
            return message
        } catch {
            throw error
        }
    }
    
    func getChatHistory(artistId: String) async throws -> [ChatMessage] {
        // Placeholder implementation
        return []
    }
}

// Supporting response structures
struct ChatResponse: Codable {
    let success: Bool?
    let data: ChatMessageData?
    let error: String?
}

struct ChatMessageData: Codable {
    let message: ChatMessage
}
