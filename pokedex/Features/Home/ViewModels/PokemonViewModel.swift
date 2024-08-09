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
    private var offset = 0
    private let limit = 5

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchNextBatchOfPokemon(completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PokemonList.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionValue in
                switch completionValue {
                case .finished:
                    self?.isLoading = false
                case .failure(let error):
                    self?.isLoading = false
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] pokemonList in
                self?.offset += self?.limit ?? 0
                self?.appendNewPokemons(pokemonList.results)
                self?.savePokemonToCoreData(pokemonList.results)
                completion(.success(pokemonList.results))
            }
            .store(in: &cancellables)
    }

    // Este método asegura que no se agreguen Pokémon duplicados
    private func appendNewPokemons(_ newPokemons: [Pokemon]) {
        let existingNames = Set(pokemonList.map { $0.name })
        let filteredPokemons = newPokemons.filter { !existingNames.contains($0.name) }
        pokemonList.append(contentsOf: filteredPokemons)
    }
    
    private func savePokemonToCoreData(_ pokemons: [Pokemon]) {
        for pokemon in pokemons {
            // Evitar guardar duplicados en Core Data también
            let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)
            
            do {
                let count = try context.count(for: fetchRequest)
                if count == 0 { // Solo guardar si no existe
                    let entity = PokemonEntity(context: context)
                    entity.name = pokemon.name
                    entity.url = pokemon.url
                    try context.save()
                    print("Saved \(pokemon.name) to Core Data")
                }
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

