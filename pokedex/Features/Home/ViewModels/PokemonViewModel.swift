//
//  HomeViewModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import Foundation
import Combine

import CoreData
import Combine
import Foundation

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    @Published var isLoading = false
    var cancellables = Set<AnyCancellable>()
    
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchPokemon() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100") else {
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonList.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLoading = false
                case .failure(let error):
                    print("Error fetching Pokémon: \(error)")
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] pokemonList in
                self?.pokemonList = pokemonList.results
                self?.savePokemonToCoreData(pokemonList.results)
            }
            .store(in: &cancellables)
    }
    
    func savePokemonToCoreData(_ pokemons: [Pokemon]) {
        for pokemon in pokemons {
            let entity = PokemonEntity(context: context)
            entity.name = pokemon.name
            entity.url = pokemon.url
            
            do {
                try context.save()
                print("Saved \(pokemon.name) to Core Data")
            } catch {
                print("Failed to save Pokémon: \(error)")
            }
        }
    }
    
    func fetchPokemonFromCoreData() {
        let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            self.pokemonList = entities.map { Pokemon(name: $0.name ?? "", url: $0.url ?? "") }
            print("Fetched \(entities.count) Pokémon from Core Data")
        } catch {
            print("Failed to fetch Pokémon from Core Data: \(error)")
        }
    }
}
