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
    
    // Sample data for development and testing
    static let sampleProductions = [
        Production(
            _id: "prod1",
            songName: "Summer Vibes",
            audioUrl: "https://example.com/audio1.mp3",
            genre: "Pop",
            referenceImageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/chainsmokers_image.png"
        ),
        Production(
            _id: "prod2",
            songName: "Midnight Dreams",
            audioUrl: "https://example.com/audio2.mp3",
            genre: "Electronic",
            referenceImageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/max_martin+(1).png"
        ),
        Production(
            _id: "prod3",
            songName: "Dance Tonight",
            audioUrl: "https://example.com/audio3.mp3",
            genre: "Dance",
            referenceImageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/yinon+image.png"
        ),
        Production(
            _id: "prod4",
            songName: "Urban Flow",
            audioUrl: "https://example.com/audio4.mp3",
            genre: "Hip-Hop",
            referenceImageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/cam_image.jpg"
        )
    ]
}

// Response type for productions list
struct ProductionsResponse: Codable {
    let productions: [Production]
    let success: Bool?
    let message: String?
}
