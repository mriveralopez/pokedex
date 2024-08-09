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
        viewModel.fetchPokemon()
        
        // Recargar la tabla cuando los datos se actualicen
        viewModel.$pokemonList.sink { [weak self] _ in
            DispatchQueue.main.async {
                print("Reloading table view")
                self?.tableView.reloadData()
            }
        }.store(in: &viewModel.cancellables)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of Pokémon: \(viewModel.pokemonList.count)")
        return viewModel.pokemonList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
        let pokemon = viewModel.pokemonList[indexPath.row]
        cell.configure(with: pokemon)
        return cell
    }
}
