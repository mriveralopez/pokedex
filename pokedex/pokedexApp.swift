//
//  pokedexApp.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

@main
struct pokedexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
