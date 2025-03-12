import Foundation

struct CreateChatResponse: Codable {
    let threadId: String
}

struct MessageContent: Codable {
    let text: String
    let type: String
    let format: String?
}

struct MessageResponse: Codable {
    let message: MessageData
}

struct MessagesResponse: Codable {
    let messages: [MessageData]
}

struct MessageData: Codable {
    let content: [MessageContent]
    let timestamp: String
    let role: String
}

struct ThreadsResponse: Codable {
    let threads: [String: ThreadData]
    
    struct ThreadData: Codable {
        let title: String
        let artistId: String
        let lastMessageAt: String?
    }
}

struct ThreadData: Codable {
    let id: String
    let title: String
} 