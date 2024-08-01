//
//  HomeViewModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var pokemonModel = [PokemonModel]()
    @Published var searchText: String = ""
    
    let baseUrl = "https://pokeapi.co/api/v2/pokemon"
    
    func fetchPokemons() {
        guard let url = URL(string: baseUrl) else { return }
        
        URLSession.shared.dataTask(with: url){
            data, response, error in if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data?.parseData(removeString: "null,") else { return }
            
            do {
                let pokemon = try JSONDecoder().decode([PokemonModel].self, from: data)
                    DispatchQueue.main.async { self.pokemonModel = pokemon
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
}
