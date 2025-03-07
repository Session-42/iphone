// File: HitCraft-Black/Core/Network/NetworkCore.swift

import Foundation

// Central network configuration namespace
enum HCNetwork {
    
    // MARK: - Environment Configuration
    enum Environment {
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
            static let base = "/api/\(Environment.apiVersion)"
            
            // Artist endpoints
            static let artists = "\(base)/artist"
            static func artist(_ id: String) -> String { "\(artists)/\(id)" }
            
            // Chat endpoints
            static let chat = "\(base)/chat"
            static func chatMessages(threadId: String) -> String { "\(chat)/\(threadId)/messages" }
            static func createChat() -> String { "\(chat)/" }
        }
    }
    
    // MARK: - Error Handling
    enum Error: Swift.Error {
        case invalidURL
        case networkError(Swift.Error)
        case serverError(code: Int, message: String?)
        case decodingError(Swift.Error)
        case unauthorized
        case serverUnavailable
        case validationError([String])
        case forbidden(String?)
        case requestFailed(String?)
    }
    
    // MARK: - API Response Types
    struct ErrorResponse: Codable {
        let error: String
    }
}

// MARK: - Error Descriptions
extension HCNetwork.Error: LocalizedError {
    var errorDescription: String? {
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
        case .requestFailed(let message):
            return message ?? "Request failed. Please try again."
        }
    }
}
