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

class PokemonTableViewController: UITableViewController, UISearchBarDelegate {
    
    private var viewModel: PokemonViewModel
    private var activityIndicator: UIActivityIndicatorView!
    private var filteredPokemonList: [Pokemon] = []
    private var searchBar: UISearchBar!
    
    init(viewModel: PokemonViewModel) {
        self.viewModel = viewModel
        self.filteredPokemonList = viewModel.pokemonList
        super.init(style: .plain)
        self.title = "Pokémon"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
        setupSearchBar()
        setupActivityIndicator()
        loadInitialData()
        
        // Recargar la tabla cuando los datos se actualicen
        viewModel.$pokemonList.sink { [weak self] pokemonList in
            DispatchQueue.main.async {
                self?.filteredPokemonList = pokemonList
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }.store(in: &viewModel.cancellables)
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Buscar Pokémon"
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
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
        return filteredPokemonList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
        let pokemon = filteredPokemonList[indexPath.row]
        cell.configure(with: pokemon)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.pokemonList.count - 1 { // Si estamos en la última celda
            loadMoreData()
        }
    }
    
    private func loadMoreData() {
        viewModel.fetchNextBatchOfPokemon { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemons):
                    print("Loaded more \(pokemons.count) Pokémon")
                case .failure(let error):
                    print("Failed to load more Pokémon: \(error)")
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPokemonList = viewModel.pokemonList
        } else {
            filteredPokemonList = viewModel.pokemonList.filter { $0.name.contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredPokemonList = viewModel.pokemonList
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
