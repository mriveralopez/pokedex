//
//  BackgroundFetchManager.swift
//  pokedex
//
//  Created by Miguel Rivera on 9/8/24.
//

import BackgroundTasks
import SwiftUI

class BackgroundFetchManager {
    static let shared = BackgroundFetchManager()

    private init() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jmrl.pokedex.pokemonrefresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()  // Reprogramar la tarea

        let context = PokemonMVVMApp().persistentContainer.viewContext
        let viewModel = PokemonViewModel(context: context)
        
        viewModel.fetchNextBatchOfPokemon { result in
            switch result {
            case .success(let newPokemon):
                if newPokemon.isEmpty {
                    task.setTaskCompleted(success: false)
                } else {
                    task.setTaskCompleted(success: true)
                    self.sendNotification(for: newPokemon.count)
                }
            case .failure:
                task.setTaskCompleted(success: false)
            }
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.jmrl.pokedex.pokemonrefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15) // 15 segundos desde ahora
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    func sendNotification(for newPokemonCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Pokémon Actualizados"
        content.body = "Se han agregado \(newPokemonCount) nuevos Pokémon a la lista."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to deliver notification: \(error)")
            } else {
                print("Notification delivered successfully")
            }
        }
    }
}
