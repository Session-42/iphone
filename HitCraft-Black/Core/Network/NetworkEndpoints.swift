import Foundation

extension HCNetwork {
    enum Endpoints {
        private static let base = "/api/v1"
        
        // Artist endpoints
        static let artists = "\(base)/artist"
        static func artist(_ id: String) -> String { "\(artists)/\(id)" }
        
        // Chat endpoints
        static let chat = "\(base)/chat"
        static func chatMessages(threadId: String) -> String { "\(chat)/\(threadId)/messages" }
        static func createChat() -> String { "\(chat)/" }
    }
} 