//
//  MenuList.swift
//  pokedex
//
//  Created by Miguel Rivera on 8/8/24.
//

import SwiftUI
import UIKit

struct PokemonListView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: PokemonViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = PokemonTableViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

class PokemonTableViewController: UITableViewController {
    
    private var viewModel: PokemonViewModel
    
    init(viewModel: PokemonViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
        loadInitialData()
        
        // Recargar la tabla cuando los datos se actualicen
        viewModel.$pokemonList.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // Método para cargar el primer lote de datos
    private func loadInitialData() {
        viewModel.fetchNextBatchOfPokemon { result in
            switch result {
            case .success(let pokemons):
                print("Loaded \(pokemons.count) Pokémon")
            case .failure(let error):
                print("Failed to load Pokémon: \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemonList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
        let pokemon = viewModel.pokemonList[indexPath.row]
        cell.configure(with: pokemon)
        return cell
    }
    
    // Método opcional: Cargar más Pokémon cuando el usuario llegue al final de la lista
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.pokemonList.count - 1 { // Si estamos en la última celda
            loadMoreData()
        }
    }
    
    private func loadMoreData() {
        viewModel.fetchNextBatchOfPokemon { result in
            switch result {
            case .success(let pokemons):
                print("Loaded more \(pokemons.count) Pokémon")
            case .failure(let error):
                print("Failed to load more Pokémon: \(error)")
            }
        }
    }
}
