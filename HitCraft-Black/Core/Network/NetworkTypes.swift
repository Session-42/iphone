import Foundation

// Centralized error type
public enum HitCraftNetworkError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(code: Int, message: String?)
    case decodingError(Error)
    case unauthorized
    case serverUnavailable
    case validationError([String])
    case forbidden(String?)
}

extension HitCraftNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return message ?? "Server error (\(code)). Please try again later."
        case .decodingError(let error):
            return "Data processing error: \(error.localizedDescription)"
        case .unauthorized:
            return "Session expired. Please sign in again."
        case .serverUnavailable:
            return "Service temporarily unavailable. Please try again later."
        case .validationError(let errors):
            return errors.joined(separator: "\n")
        case .forbidden(let message):
            return message ?? "Access denied. Please check your permissions."
        }
    }
}

// Centralized configuration type
public enum HitCraftNetworkConfiguration {
    public static let baseURL = "https://api.dev.hitcraft.ai:8080"
    public static let webAppURL = "https://app.dev.hitcraft.ai"
    public static let authBaseURL = "https://auth.dev.hitcraft.ai"
    
    public static let apiVersion = "v1"
    
    public enum Endpoints {
        public static let baseRoute = "/api/\(HitCraftNetworkConfiguration.apiVersion)"
        
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
