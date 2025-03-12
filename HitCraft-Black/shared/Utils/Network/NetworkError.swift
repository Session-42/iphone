import Foundation

extension HCNetwork {
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