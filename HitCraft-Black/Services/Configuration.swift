import Foundation

enum HCEnvironment {
    // Base URLs
    static let apiBaseURL = "https://api.dev.hitcraft.ai:8080"
    static let webAppURL = "https://app.dev.hitcraft.ai"
    static let authBaseURL = "https://auth.dev.hitcraft.ai"
    
    // Auth Configuration
    static let descopeProjectId = "P2rIvbtGcXTcUfT68LGuVqPitlJd"
    
    // API Versioning
    static let apiVersion = "v1"
    
    // API Endpoints
    enum Endpoint {
        static let base = "/api/\(HCEnvironment.apiVersion)"
        
        // Artist endpoints
        static let artists = "\(base)/artist"
        static func artist(_ id: String) -> String { "\(artists)/\(id)" }
        
        // Chat endpoints
        static let chat = "\(base)/chat"
        static func chatMessages(threadId: String) -> String { "\(chat)/\(threadId)/messages" }
        static func createChat(artistId: String) -> String { "\(chat)/" }
    }
}
