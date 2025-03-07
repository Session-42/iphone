// File: HitCraft-Black/Models/ChatMessage.swift

import Foundation

struct ChatMessage: Codable, Identifiable, Hashable {
    var id: UUID
    let content: String
    let sender: String
    let type: String
    let timestamp: Date
    
    var isFromUser: Bool {
        return sender == "user"
    }
    
    var text: String {
        return content
    }
    
    init(id: UUID = UUID(), content: String, sender: String, type: String = "text", timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.sender = sender
        self.type = type
        self.timestamp = timestamp
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case content
        case sender
        case type
        case timestamp
    }
    
    // Custom decoding to handle potential string ID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringId = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: stringId) ?? UUID()
        } else {
            self.id = UUID()
        }
        self.content = try container.decode(String.self, forKey: .content)
        self.sender = try container.decode(String.self, forKey: .sender)
        self.type = try container.decode(String.self, forKey: .type)
        
        // Handle potential string timestamp
        if let timestampString = try? container.decode(String.self, forKey: .timestamp),
           let date = ISO8601DateFormatter().date(from: timestampString) {
            self.timestamp = date
        } else {
            self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}
