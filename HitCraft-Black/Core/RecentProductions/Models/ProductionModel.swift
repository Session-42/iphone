// File: HitCraft-Black/Models/Production.swift

import Foundation

struct Production: Identifiable, Hashable, Codable {
    // Using _id from the API as the identifier
    var id: String { _id }
    let _id: String
    let songName: String
    let audioUrl: String
    let genre: String
    
    // Additional properties (optional)
    var referenceImageUrl: String?
    
    // Required for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }
    
    static func == (lhs: Production, rhs: Production) -> Bool {
        lhs._id == rhs._id
    }
}

// Response type for productions list
struct ProductionsResponse: Codable {
    let productions: [Production]
    let success: Bool?
    let message: String?
}
