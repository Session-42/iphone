import Foundation

enum ApiError: Error {
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
        }
    }
}
