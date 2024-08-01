//
//  PokemonModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

struct PokemonModel: Codable, Identifiable {
    var id: String { name }
    let name: String
    let url: String
}
