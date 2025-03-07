import Foundation

public struct ArtistProfile: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let imageUrl: String?
    
    public init(
        id: String,
        name: String,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ArtistProfile, rhs: ArtistProfile) -> Bool {
        lhs.id == rhs.id
    }
}
