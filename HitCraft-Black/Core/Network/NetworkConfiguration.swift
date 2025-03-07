import Foundation

public enum NetworkConfiguration {
    public static let baseURL = "https://api.dev.hitcraft.ai:8080"
    public static let webAppURL = "https://app.dev.hitcraft.ai"
    public static let authBaseURL = "https://auth.dev.hitcraft.ai"
    
    public static let apiVersion = "v1"
    
    public enum Endpoints {
        public static let baseRoute = "/api/\(NetworkConfiguration.apiVersion)"
        
        public enum Artist {
            public static let base = "\(baseRoute)/artist"
            public static func getArtist(_ id: String) -> String {
                return "\(base)/\(id)"
            }
        }
        
        public enum Chat {
            public static let base = "\(baseRoute)/chat"
            public static func messages(threadId: String) -> String {
                return "\(base)/\(threadId)/messages"
            }
        }
    }
}
