//
//  ServiceModel.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

struct ServiceModel: Codable {
    let count: Int
    let next: String
    let previous: String?
    let results: [PokemonModel]
}
