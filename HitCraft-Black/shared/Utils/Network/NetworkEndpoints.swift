import Foundation
extension HCNetwork {
    enum Endpoints {
        private static let base = "/api/v1"
        
        // Artist endpoints
        static let artists = "\(base)/artist"
        static func artist(_ id: String) -> String { "\(artists)/\(id)" }
        
        // Chat endpoints
        static let chat = "\(base)/chat"
        
        // Existing endpoints
        static func chatMessages(threadId: String) -> String { "\(chat)/\(threadId)/messages" }
        static func createChat() -> String { "\(chat)/" }
        
        // New endpoints
        static func chat(threadId: String) -> String { "\(chat)/\(threadId)" }
        static func listChats(amount: Int = 3) -> String { "\(chat)/?amount=\(amount)" }
        static func listChatsByArtist(artistId: String) -> String { "\(chat)/artist/?artistId=\(artistId)" }
        static func listChatsByArtistWithAmount(artistId: String, amount: Int) -> String { 
            "\(chat)/?artistId=\(artistId)&amount=\(amount)" 
        }
        static func confirmUserMessage() -> String { "\(chat)/confirmation" }
        static func lastMessage(threadId: String) -> String { "\(chat)/\(threadId)/last-message" }
        static func chatTitle(threadId: String) -> String { "\(chat)/\(threadId)/title" }
    }
}