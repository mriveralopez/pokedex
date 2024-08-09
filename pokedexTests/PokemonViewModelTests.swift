//
//  PokemonViewModelTests.swift
//  pokedexTests
//
//  Created by Miguel Rivera on 9/8/24.
//

import XCTest
import CoreData
@testable import pokedex

class PokemonViewModelTests: XCTestCase {

    var persistentContainer: NSPersistentContainer!
    var viewModel: PokemonViewModel!

    override func setUpWithError() throws {
        persistentContainer = {
            let container = NSPersistentContainer(name: "PokemonModel")
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { (description, error) in
                XCTAssertNil(error)
            }
            return container
        }()

        viewModel = PokemonViewModel(context: persistentContainer.viewContext)
    }

    override func tearDownWithError() throws {
        persistentContainer = nil
        viewModel = nil
    }

    func testSavingPokemonToCoreData() throws {
        // Dado un Pokémon de prueba
        let testPokemon = Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        
        // Cuando se guarda en Core Data
        try viewModel.savePokemonToCoreData([testPokemon])
        
        // Entonces debería recuperarse correctamente
        let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        let results = try persistentContainer.viewContext.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1, "Debería haber un Pokémon guardado en Core Data")
        XCTAssertEqual(results.first?.name, "bulbasaur", "El nombre del Pokémon guardado debería ser 'bulbasaur'")
        XCTAssertEqual(results.first?.url, "https://pokeapi.co/api/v2/pokemon/1/", "La URL del Pokémon guardado debería coincidir")
    }

    func testFetchingPokemonFromCoreData() throws {
        // Dado un Pokémon guardado en Core Data
        let testPokemon = Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        try viewModel.savePokemonToCoreData([testPokemon])
        
        // Cuando se recupera desde Core Data
        viewModel.fetchPokemonFromCoreData()
        
        // Entonces debería estar disponible en el ViewModel
        XCTAssertEqual(viewModel.pokemonList.count, 1, "Debería haber un Pokémon recuperado desde Core Data")
        XCTAssertEqual(viewModel.pokemonList.first?.name, "bulbasaur", "El nombre del Pokémon recuperado debería ser 'bulbasaur'")
        XCTAssertEqual(viewModel.pokemonList.first?.url, "https://pokeapi.co/api/v2/pokemon/1/", "La URL del Pokémon recuperado debería coincidir")
    }
}
