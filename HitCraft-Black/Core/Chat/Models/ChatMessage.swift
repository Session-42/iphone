import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let content: String
    let sender: String
    let timestamp: Date
    
    var isFromUser: Bool {
        return sender == "user"
    }
    
    init(id: UUID = UUID(), content: String, sender: String, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
}
