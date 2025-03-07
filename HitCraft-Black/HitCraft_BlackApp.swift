//
//  HitCraft_BlackApp.swift
//  HitCraft-Black
//
//  Created by Oudi Antebi on 07/03/2025.
//

import SwiftUI

@main
struct HitCraft_BlackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
