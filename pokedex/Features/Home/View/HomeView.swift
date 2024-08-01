//
//  HomeView.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

struct HomeView: View{
    @ObservedObject var viewModel = homeViewModel()
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    private let gridItems = [GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                LazyVGrid(columns: gridItems, spacing:16){
                    ForEach(filteredPokemon){
                        pokemon in PokemonCell(pokemon: pokemon,isDarkMode: isDarkMode)
                    }
                }
            }.padding(.horizontal,8).ignoresSafeArea(.all, edges: .bottom).navigationBarTitleDisplayMode(.inline).navigationBarItems(leading: HStack{
                                Image("Pokeball").resizable().frame(width: 40,height: 40)
                Text("Pokedex").font(Font.system(size: 26))
            }, trailing: HStack { Button(action: {
                isDarkMode.toggle()
            }) {
                Image(systemName: isDarkMode ? "moon.circle.fill" : "sun.max.fill").font(.title)
            }
                Spacer().searchable(text: $viewModel.searchText)
            })
        }
        .onAppear {
            viewModel.fetchPokemons()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    
    private var filteredPokemon: [PokemonModel] {
        return viewModel.searchText.isEmpty ? viewModel.serviceModel?.results ?? [] : (viewModel.serviceModel?.results ?? []) .filter{
            $0.name.lowercased().contains(viewModel.searchText.lowercased())
        }
    }
}

#Preview {
    HomeView(viewModel: homeViewModel())
}
