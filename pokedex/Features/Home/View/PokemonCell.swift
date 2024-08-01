//
//  PokemonCell.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

struct PokemonCell: View{
    let pokemon: PokemonModel
    let isDarkMode: Bool
    @State private var image: UIImage?
             
    var body: some View{
        HStack {
            title
        }
    }
    
    var title: some View {
        Text(pokemon.name.capitalized).font(.headline).bold().foregroundColor(isDarkMode ? .white : .black)
    }
}

#Preview {
    HomeView(viewModel: homeViewModel())
}
