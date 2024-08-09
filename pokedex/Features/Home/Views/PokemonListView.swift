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
    private var activityIndicator: UIActivityIndicatorView!
    
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
        setupActivityIndicator()
        loadInitialData()
        
        // Recargar la tabla cuando los datos se actualicen
        viewModel.$pokemonList.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }.store(in: &viewModel.cancellables)
    }

    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadInitialData() {
        activityIndicator.startAnimating()
        viewModel.fetchNextBatchOfPokemon { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let pokemons):
                    print("Loaded \(pokemons.count) Pokémon")
                case .failure(let error):
                    print("Failed to load Pokémon: \(error)")
                }
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

}
