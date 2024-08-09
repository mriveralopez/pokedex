//
//  PokemonModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import Foundation

struct Pokemon: Codable {
    let name: String
    let url: String
    
    var pokemonID: Int {
        let idString = url.split(separator: "/").last ?? "0"
        return Int(idString) ?? 0
    }
    
    var imageURL: URL {
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonID).png")!
    }
}

struct PokemonList: Codable {
    let results: [Pokemon]
}
