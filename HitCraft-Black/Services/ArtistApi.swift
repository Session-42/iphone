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
    
    public static let shared = ArtistApi()
    
    private init(apiClient: ApiClient = .shared) {
        self.apiClient = apiClient
    }
    
    public func list() async throws -> [ArtistProfile] {
        let response: ArtistsResponse = try await apiClient.get(
            path: "/api/v1/artist"  // Hardcoded path since NetworkConfiguration is causing issues
        )
        return Array(response.artists.values).sorted { $0.name < $1.name }
    }
    
    public func get(artistId: String) async throws -> ArtistProfile {
        return try await apiClient.get(
            path: "/api/v1/artist/\(artistId)"  // Hardcoded path
        )
    }
}
