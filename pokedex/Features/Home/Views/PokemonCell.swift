//
//  PokemonCell.swift
//  pokedex
//
//  Created by Miguel Rivera on 1/8/24.
//

import SwiftUI

class PokemonCell: UITableViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView(arrangedSubviews: [pokemonImageView, nameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pokemonImageView.widthAnchor.constraint(equalToConstant: 50),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 50),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Añadir selección visualmente atractiva
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with pokemon: Pokemon) {
        nameLabel.text = pokemon.name.capitalized
        nameLabel.accessibilityLabel = "Nombre del Pokémon: \(pokemon.name.capitalized)"
        
        pokemonImageView.image = nil
        URLSession.shared.dataTask(with: pokemon.imageURL) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self?.pokemonImageView.image = UIImage(data: data)
                self?.pokemonImageView.accessibilityLabel = "\(pokemon.name.capitalized) imagen"
            }
        }.resume()
    }

}
