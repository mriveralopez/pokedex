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
    @Published var errorMessage: String?
    var cancellables = Set<AnyCancellable>()
    
    private let context: NSManagedObjectContext
    private var offset = 0
    private let limit = 5

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchNextBatchOfPokemon(completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])
            self.errorMessage = error.localizedDescription
            completion(.failure(error))
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
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] pokemonList in
                self?.offset += self?.limit ?? 0
                self?.appendNewPokemons(pokemonList.results)
                do {
                    try self?.savePokemonToCoreData(pokemonList.results)
                    completion(.success(pokemonList.results))
                } catch {
                    self?.errorMessage = "Error al guardar en Core Data: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
            .store(in: &cancellables)
    }

    private func appendNewPokemons(_ newPokemons: [Pokemon]) {
        let existingNames = Set(pokemonList.map { $0.name })
        let filteredPokemons = newPokemons.filter { !existingNames.contains($0.name) }
        pokemonList.append(contentsOf: filteredPokemons)
    }
    
    func savePokemonToCoreData(_ pokemons: [Pokemon]) throws {
        for pokemon in pokemons {
            let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", pokemon.name)
            
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let entity = PokemonEntity(context: context)
                entity.name = pokemon.name
                entity.url = pokemon.url
                try context.save()
                print("Saved \(pokemon.name) to Core Data")
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
            self.errorMessage = "Error al recuperar de Core Data: \(error.localizedDescription)"
            print("Failed to fetch Pokémon from Core Data: \(error)")
        }
    }
}
