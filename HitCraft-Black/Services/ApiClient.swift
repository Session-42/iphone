// File: HitCraft-Black/Services/ApiClient.swift

import Foundation
import DescopeKit

@MainActor
final class ApiClient {
    // MARK: - Properties
    static let shared = ApiClient()
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let timeoutInterval: TimeInterval = 30
    
    // MARK: - Initialization
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval
        
        self.urlSession = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    func get<T: Codable>(path: String) async throws -> T {
        return try await request(path: path, method: "GET")
    }
    
    func post<T: Codable>(path: String, body: [String: Any]? = nil) async throws -> T {
        return try await request(path: path, method: "POST", body: body)
    }
    
    func post(path: String, body: [String: Any]? = nil) async throws -> [String: Any] {
        return try await requestAnyResponse(path: path, method: "POST", body: body)
    }
    
    // MARK: - Private Request Methods
    private func request<T: Codable>(path: String, method: String, body: [String: Any]? = nil) async throws -> T {
        let fullURL = HCNetwork.Environment.apiBaseURL + path
        print("🚀 \(method) \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            throw HCNetwork.Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        
        // Set standard headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(HCNetwork.Environment.webAppURL, forHTTPHeaderField: "Origin")
        
        do {
            // Add authentication headers
            try addAuthenticationHeaders(&request)
            
            // Set request body for POST/PUT methods
            if let body = body, (method == "POST" || method == "PUT") {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                print("📦 Request Body: \(body)")
            }
            
            // Perform the request
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HCNetwork.Error.networkError(NSError(domain: "ApiClient", code: -1))
            }
            
            print("📡 Response Status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                let preview = responseString.count > 500 ? String(responseString.prefix(500)) + "..." : responseString
                print("📄 Response Data: \(preview)")
            }
            
            // Handle response based on status code
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    // Check for API error in response
                    if let errorResponse = try? decoder.decode(HCNetwork.ErrorResponse.self, from: data),
                       !errorResponse.error.isEmpty {
                        throw HCNetwork.Error.serverError(code: httpResponse.statusCode, message: errorResponse.error)
                    }
                    
                    // Try to decode as the expected type
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("❌ Decoding error: \(error)")
                    throw HCNetwork.Error.decodingError(error)
                }
            case 401, 403:
                throw HCNetwork.Error.unauthorized
            case 503:
                throw HCNetwork.Error.serverUnavailable
            default:
                if let errorResponse = try? decoder.decode(HCNetwork.ErrorResponse.self, from: data) {
                    throw HCNetwork.Error.serverError(code: httpResponse.statusCode, message: errorResponse.error)
                }
                throw HCNetwork.Error.serverError(code: httpResponse.statusCode, message: nil)
            }
        } catch let error as HCNetwork.Error {
            throw error
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            throw HCNetwork.Error.networkError(error)
        }
    }
    
    private func requestAnyResponse(path: String, method: String, body: [String: Any]? = nil) async throws -> [String: Any] {
        let fullURL = HCNetwork.Environment.apiBaseURL + path
        print("🚀 \(method) \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            throw HCNetwork.Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        
        // Set standard headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(HCNetwork.Environment.webAppURL, forHTTPHeaderField: "Origin")
        
        do {
            // Add authentication headers
            try addAuthenticationHeaders(&request)
            
            // Set request body for POST/PUT methods
            if let body = body, (method == "POST" || method == "PUT") {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                print("📦 Request Body: \(body)")
            }
            
            // Perform the request
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HCNetwork.Error.networkError(NSError(domain: "ApiClient", code: -1))
            }
            
            print("📡 Response Status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                let preview = responseString.count > 500 ? String(responseString.prefix(500)) + "..." : responseString
                print("📄 Response Data: \(preview)")
            }
            
            // Handle response based on status code
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    // If the response is empty or null, return an empty dictionary
                    if data.isEmpty || (String(data: data, encoding: .utf8) == "null") {
                        return [:]
                    }
                    
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        return json
                    } else {
                        throw HCNetwork.Error.decodingError(NSError(domain: "Decoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    throw HCNetwork.Error.decodingError(error)
                }
            case 401, 403:
                throw HCNetwork.Error.unauthorized
            case 503:
                throw HCNetwork.Error.serverUnavailable
            default:
                if let errorResponse = try? decoder.decode(HCNetwork.ErrorResponse.self, from: data) {
                    throw HCNetwork.Error.serverError(code: httpResponse.statusCode, message: errorResponse.error)
                }
                throw HCNetwork.Error.serverError(code: httpResponse.statusCode, message: nil)
            }
        } catch let error as HCNetwork.Error {
            throw error
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            throw HCNetwork.Error.networkError(error)
        }
    }
    
    // MARK: - Helper Methods
    private func addAuthenticationHeaders(_ request: inout URLRequest) throws {
        guard let session = Descope.sessionManager.session else {
            throw HCNetwork.Error.unauthorized
        }
        
        let token = session.sessionToken.jwt
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
