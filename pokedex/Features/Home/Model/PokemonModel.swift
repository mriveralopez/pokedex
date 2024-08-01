//
//  PokemonModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

struct PokemonModel: Codable, Identifiable {
    
    enum PokemonType: String, Codable {
        case fire, poison, water, electric, psychic, normal, ground, flying, fairy, none
    }
    
    let id: Int
    let name: String
    let imageUrl: String
    private let type: String
    var pokemonType: PokemonType{
        return PokemonType(rawValue:type) ?? .none
    }
}
