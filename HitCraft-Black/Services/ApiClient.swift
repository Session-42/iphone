import Foundation
import DescopeKit

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
        guard let url = URL(string: HitCraftNetworkConfiguration.baseURL + path) else {
            throw HitCraftNetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        try addAuthenticationHeaders(&request)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HitCraftNetworkError.networkError(NSError(domain: "", code: -1))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw HitCraftNetworkError.decodingError(error)
                }
            case 401, 403:
                throw HitCraftNetworkError.unauthorized
            case 503:
                throw HitCraftNetworkError.serverUnavailable
            default:
                throw HitCraftNetworkError.serverError(code: httpResponse.statusCode, message: nil)
            }
        } catch {
            throw HitCraftNetworkError.networkError(error)
        }
    }
    
    private func addAuthenticationHeaders(_ request: inout URLRequest) throws {
        guard let session = Descope.sessionManager.session else {
            throw HitCraftNetworkError.unauthorized
        }
        
        let token = session.sessionToken.jwt
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
