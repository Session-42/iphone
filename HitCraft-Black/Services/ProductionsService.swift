// File: HitCraft-Black/Services/ProductionsService.swift

import Foundation

@MainActor
final class ProductionsService {
    // MARK: - Properties
    private let apiClient: ApiClient
    
    static let shared = ProductionsService(apiClient: .shared)
    
    // MARK: - Initialization
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    /// Fetch all productions without limiting
    func getRecentProductions() async throws -> [Production] {
        // Use the endpoint that matches your API
        let path = "/api/v1/production"
        
        // Make API request without limiting the number of results
        let response: ProductionsResponse = try await apiClient.get(path: path)
        
        // Return the productions list
        return response.productions
    }
    
    /// Get reference image for a production
    func getProductionImage(productionId: String) async throws -> URL? {
        // Use the endpoint to fetch production image
        let path = "/api/v1/production/\(productionId)/image"
        
        // Make API request to get image URL
        let response: ImageResponse = try await apiClient.get(path: path)
        
        // Return the image URL if available
        if let imageUrl = response.imageUrl, let url = URL(string: imageUrl) {
            return url
        }
        return nil
    }
    
    /// Download a production's audio file
    func downloadProduction(audioUrl: String, fileName: String) async throws -> URL {
        // Check if the audioUrl is valid
        guard let url = URL(string: audioUrl) else {
            throw HCNetwork.Error.invalidURL
        }
        
        // In a real implementation, you would download the file to a local path
        // For now, we'll just return the URL to simulate success
        return url
    }
    
    /// Play a production's audio
    func playProduction(audioUrl: String) async throws -> Bool {
        // This would integrate with your audio player
        // For now, return true to indicate success
        return true
    }
    
    /// Select a production
    func selectProduction(productionId: String) async throws -> Bool {
        // Use the endpoint to select a production
        let path = "/api/v1/production/select"
        
        // Prepare request body
        let body: [String: Any] = [
            "productionId": productionId
        ]
        
        // Make API request
        let response: SelectProductionResponse = try await apiClient.post(path: path, body: body)
        
        return response.success
    }
}

// Response type for image URL
struct ImageResponse: Codable {
    let imageUrl: String?
    let success: Bool
}

// Response type for selecting a production
struct SelectProductionResponse: Codable {
    let success: Bool
    let message: String?
}
