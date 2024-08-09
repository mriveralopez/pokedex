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
            .onAppear {
                viewModel.fetchPokemonFromCoreData()
            }
    }
}
