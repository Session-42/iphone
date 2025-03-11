// File: HitCraft-Black/Models/ArtistProfile.swift

import Foundation
import SwiftUI

public struct ArtistProfile: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let imageUrl: String?
    
    public var instructions: String?
    public var phoneNumber: String?
    public var birthdate: String?
    public var about: String?
    public var biography: [String]?
    public var role: ArtistRole?
    public var livesIn: String?
    public var musicalAchievements: [String]?
    public var businessAchievements: [String]?
    public var preferredGenres: [String]?
    public var famousWorks: [String]?
    public var socialMediaLinks: [String]?
    
    // Initializer with required fields
    public init(
        id: String,
        name: String,
        imageUrl: String? = nil,
        instructions: String? = nil,
        phoneNumber: String? = nil,
        birthdate: String? = nil,
        about: String? = nil,
        biography: [String]? = nil,
        role: ArtistRole? = nil,
        livesIn: String? = nil,
        musicalAchievements: [String]? = nil,
        businessAchievements: [String]? = nil,
        preferredGenres: [String]? = nil,
        famousWorks: [String]? = nil,
        socialMediaLinks: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.instructions = instructions
        self.phoneNumber = phoneNumber
        self.birthdate = birthdate
        self.about = about
        self.biography = biography
        self.role = role
        self.livesIn = livesIn
        self.musicalAchievements = musicalAchievements
        self.businessAchievements = businessAchievements
        self.preferredGenres = preferredGenres
        self.famousWorks = famousWorks
        self.socialMediaLinks = socialMediaLinks
    }
    
    // Hashable implementation
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ArtistProfile, rhs: ArtistProfile) -> Bool {
        lhs.id == rhs.id
    }
    
    // Sample data
    public static let sampleArtists = [
        ArtistProfile(
            id: "67618ad67dc13643acff6a25",
            name: "HitCraft",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/hiti.svg",
            about: "Your AI music assistant",
            role: ArtistRole(primary: "AI Music Assistant")
        )
    ]
    
    public static let sample = sampleArtists[0]
}

// MARK: - Artist Role
public struct ArtistRole: Codable, Hashable {
    public let primary: String
    public var secondary: [String]?
    
    public init(primary: String, secondary: [String]? = nil) {
        self.primary = primary
        self.secondary = secondary
    }
}
