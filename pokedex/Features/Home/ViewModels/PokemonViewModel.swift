//
//  HomeViewModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import Foundation
import Combine

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    @Published var isLoading = false
    var cancellables = Set<AnyCancellable>()
    
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
                print("Pokémon fetched: \(pokemonList.results.count)")
                self?.pokemonList = pokemonList.results
            }
            .store(in: &cancellables)
    }
}
