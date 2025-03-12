import Foundation
extension HCNetwork {
    enum Endpoints {
        private static let base = "/api/v1"
        
        // Artist endpoints
        static let artists = "\(base)/artist"
        static func artist(_ id: String) -> String { "\(artists)/\(id)" }
        static func getReferenceById(_ artistId: String, referenceId: String) -> String { "\(artists)/\(artistId)/references/\(referenceId)" }
        
        // Chat endpoints
        static let chat = "\(base)/chat"
        static func chatMessages(threadId: String) -> String { "\(chat)/\(threadId)/messages" }
        static func createChat() -> String { "\(chat)/" }
        static func chat(threadId: String) -> String { "\(chat)/\(threadId)" }
        static func listChats(amount: Int = 3) -> String { "\(chat)/?amount=\(amount)" }
        static func listChatsByArtist(artistId: String) -> String { "\(chat)/artist/?artistId=\(artistId)" }
        static func listChatsByArtistWithAmount(artistId: String, amount: Int) -> String { 
            "\(chat)/?artistId=\(artistId)&amount=\(amount)" 
        }
    }
}