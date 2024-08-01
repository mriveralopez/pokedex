//
//  HomeViewModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

class homeViewModel: ObservableObject {
    
    @Published var serviceModel: ServiceModel?
    @Published var searchText: String = ""
    
    let baseUrl = "https://pokeapi.co/api/v2/pokemon"
    
    func fetchPokemons() {
        guard let url = URL(string: baseUrl) else { return }
        
        URLSession.shared.dataTask(with: url){
            data, response, error in if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data?.parseData(removeString: "") else { return }
            
            do {
                let pokemon = try JSONDecoder().decode(ServiceModel.self, from: data)
                    DispatchQueue.main.async {
                        self.serviceModel = pokemon
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
}
