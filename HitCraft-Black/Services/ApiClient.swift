import Foundation
import DescopeKit

// Ensure these are defined in your NetworkCore file
public enum ApiError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(code: Int, message: String?)
    case decodingError(Error)
    case unauthorized
    case serverUnavailable
}

public enum HCEnvironment {
    public static let apiBaseURL = "https://api.dev.hitcraft.ai:8080"
    
    public enum Endpoint {
        public static let base = "/api/v1"
        // Add other endpoints as needed
    }
}

@MainActor
public final class ApiClient {
    public static let shared = ApiClient()
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.urlSession = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    public func get<T: Codable>(path: String) async throws -> T {
        guard let url = URL(string: HCEnvironment.apiBaseURL + path) else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        try addAuthenticationHeaders(&request)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.networkError(NSError(domain: "", code: -1))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw ApiError.decodingError(error)
                }
            case 401, 403:
                throw ApiError.unauthorized
            case 503:
                throw ApiError.serverUnavailable
            default:
                throw ApiError.serverError(code: httpResponse.statusCode, message: nil)
            }
        } catch {
            throw ApiError.networkError(error)
        }
    }
    
    public func post<T: Codable>(path: String, body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: HCEnvironment.apiBaseURL + path) else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        try addAuthenticationHeaders(&request)
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.networkError(NSError(domain: "", code: -1))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw ApiError.decodingError(error)
                }
            case 401, 403:
                throw ApiError.unauthorized
            case 503:
                throw ApiError.serverUnavailable
            default:
                throw ApiError.serverError(code: httpResponse.statusCode, message: nil)
            }
        } catch {
            throw ApiError.networkError(error)
        }
    }
    
    private func addAuthenticationHeaders(_ request: inout URLRequest) throws {
        guard let session = Descope.sessionManager.session else {
            throw ApiError.unauthorized
        }
        
        let token = session.sessionToken.jwt
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
