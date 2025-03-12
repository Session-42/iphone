import Foundation

@MainActor
final class ArtistApi {
    // MARK: - Properties
    private let apiClient: ApiClient
    
    static let shared = ArtistApi(apiClient: .shared)
    
    // MARK: - Initialization
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func list() async throws -> [ArtistProfile] {
        do {
            let response: ArtistsResponse = try await apiClient.get(
                path: HCNetwork.Endpoints.artists
            )
            return response.artists.values.sorted { $0.name < $1.name }
        } catch {
            print("Error fetching artists: \(error)")
            // Return sample data for development/testing
            return ArtistProfile.sampleArtists
        }
    }
    
    func get(artistId: String) async throws -> ArtistProfile {
        do {
            return try await apiClient.get(
                path: HCNetwork.Endpoints.artist(artistId)
            )
        } catch {
            print("Error fetching artist with ID \(artistId): \(error)")
            // Return sample data for the requested artist or default
            return ArtistProfile.sampleArtists.first(where: { $0.id == artistId }) ?? ArtistProfile.sample
        }
    }
}

// MARK: - Response Types
struct ArtistsResponse: Codable {
    let artists: [String: ArtistProfile]
}