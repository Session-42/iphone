import Foundation

enum HCNetwork {
    enum Endpoints {
        // Base URLs
        // static let apiBaseURL = "https://api.dev.hitcraft.ai:8080"
        static let apiBaseURL = "http://localhost:3500"
        static let authBaseURL = "https://auth.dev.hitcraft.ai"
        
        private static let base = "/api/v1"
        
        // Artist endpoints
        static let artists = "\(base)/artist"
        static func artist(_ id: String) -> String { "\(artists)/\(id)" }
        static func getReferenceById(_ artistId: String, referenceId: String) -> String { "\(artists)/\(artistId)/references/\(referenceId)" }
        
        // Chat endpoints
        static let chat = "\(base)/chat"
        static func createChat() -> String { "\(chat)/" }
        static func chatMessages(threadId: String) -> String { "\(chat)/\(threadId)/messages" }
        static func listChats(amount: Int = 3) -> String { "\(chat)/?amount=\(amount)" } // TODO: Change to by artist
        static func deleteChat(threadId: String) -> String { "\(chat)/\(threadId)" }

        // Sketch endpoints
        static let sketch = "\(base)/sketch"
        static func uploadSketch() -> String { "\(sketch)/" }
    }
}