import Foundation
import DescopeKit

public struct ArtistsResponse: Codable {
    public let artists: [String: ArtistProfile]
    
    public init(artists: [String: ArtistProfile]) {
        self.artists = artists
    }
}

@MainActor
public final class ArtistApi {
    private let apiClient: ApiClient
    
    public static let shared = ArtistApi(apiClient: .shared)
    
    public init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }
    
    public func list() async throws -> [ArtistProfile] {
        let response: ArtistsResponse = try await apiClient.get(
            path: HitCraftNetworkConfiguration.Endpoints.Artist.base
        )
        return Array(response.artists.values).sorted { $0.name < $1.name }
    }
    
    public func get(artistId: String) async throws -> ArtistProfile {
        return try await apiClient.get(
            path: HitCraftNetworkConfiguration.Endpoints.Artist.getArtist(artistId)
        )
    }
}
