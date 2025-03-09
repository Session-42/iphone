// File: HitCraft-Black/Core/Network/HCNetwork-Productions.swift

import Foundation

// MARK: - Productions Endpoints Extension
extension HCNetwork.Environment.Endpoint {
    // Production endpoints
    // Add these to your existing Endpoint enum
    
    // GET all productions for the current user
    static let productions = "\(base)/production"
    
    // GET a specific production by ID
    static func production(_ id: String) -> String { "\(productions)/\(id)" }
    
    // GET image for a specific production
    static func productionImage(_ id: String) -> String { "\(production(id))/image" }
    
    // POST to select a production
    static let selectProduction = "\(productions)/select"
    
    // POST to download a production
    static let downloadProduction = "\(productions)/download"
}
