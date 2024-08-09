//
//  pokedexApp.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import CoreData
import SwiftUI

@main
struct pokedexApp: App {
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PokemonModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistentContainer.viewContext)
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .onAppear {
                    BackgroundFetchManager.shared.scheduleAppRefresh()
                }
        }
    }
}
