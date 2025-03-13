import Foundation

@MainActor
final class SketchService {
    private let apiClient: ApiClient
    static let shared = SketchService(apiClient: .shared)
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func uploadSketch(fileURL: URL, postProcess: String? = nil) async throws -> UploadSketchResponse {
        do {
            let path = HCNetwork.Endpoints.uploadSketch()
            
            // Prepare additional fields
            var additionalFields: [String: String]?
            if let postProcess = postProcess {
                additionalFields = ["postProcess": postProcess]
            }
            
            // Upload the file using the ApiClient's multipart form data method
            return try await apiClient.uploadMultipartFormData(
                path: path,
                fileURL: fileURL,
                additionalFields: additionalFields
            )
        } catch HCNetwork.Error.unauthorized {
            await HCAuthService.shared.logout()
            throw HCNetwork.Error.unauthorized
        } catch {
            print("Error uploading sketch: \(error.localizedDescription)")
            throw error
        }
    }
}

// Response type for sketch upload
struct UploadSketchResponse: Codable {
    let sketchId: String
} 