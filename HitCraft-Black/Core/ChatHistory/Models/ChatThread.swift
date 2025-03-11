import SwiftUI

struct ChatThread: Identifiable {
    let id: String
    let title: String
    let artistId: String
    let lastMessageAt: Date
    
    init(id: String, data: ThreadsResponse.ThreadData) {
        self.id = id
        self.title = data.title
        self.artistId = data.artistId
        
        // Parse the lastMessageAt date
        if let dateString = data.lastMessageAt {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.lastMessageAt = formatter.date(from: dateString) ?? Date()
        } else {
            self.lastMessageAt = Date()
        }
    }
}