import Foundation

// Centralized Error Handling
public enum ApiError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(code: Int, message: String?)
    case decodingError(Error)
    case unauthorized
    case serverUnavailable
    case validationError([String])
    case forbidden(String?)
}

extension ApiError: LocalizedError {
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

// Centralized Environment Configuration
public enum HCEnvironment {
    public static let apiBaseURL = "https://api.dev.hitcraft.ai:8080"
    public static let webAppURL = "https://app.dev.hitcraft.ai"
    public static let authBaseURL = "https://auth.dev.hitcraft.ai"
    
    public static let apiVersion = "v1"
    
    public enum Endpoint {
        public static let base = "/api/\(HCEnvironment.apiVersion)"
        
        // Artist endpoints
        public static let artists = "\(base)/artist"
        public static func artist(_ id: String) -> String { "\(artists)/\(id)" }
        
        // Chat endpoints
        public static let chat = "\(base)/chat"
        public static func chatMessages(threadId: String) -> String { "\(chat)/\(threadId)/messages" }
    }
}
