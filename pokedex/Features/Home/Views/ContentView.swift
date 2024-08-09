//
//  HomeView.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: PokemonViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: PokemonViewModel(context: context))
    }

    var body: some View {
        PokemonListView(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown Error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.fetchNextBatchOfPokemon { result in
                    switch result {
                    case .success(let pokemons):
                        print("Loaded initial batch: \(pokemons.count)")
                    case .failure(let error):
                        print("Failed to load initial batch: \(error.localizedDescription)")
                    }
                }
            }
    }
}

