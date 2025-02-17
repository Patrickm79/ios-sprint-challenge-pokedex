//
//  Pokemon Controller.swift
//  iOS12-Pokedex
//
//  Created by Patrick Millet on 12/6/19.
//  Copyright © 2019 Patrick Millet. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
}

enum ErrorType: Error {
    case badData
    case noDecode
    case otherError
    case badName
    case noPokemon
    case noImage
}

class PokemonController {
    
    // MARK: - Properties
    
    let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    struct PropertyKeys {
        static let sortMethodKey = "ShouldSortBy"
    }
    
    struct HTTPMethod {
        static let get = "GET"
    }
    
    enum ErrorType: Error {
        case badResponse, otherError, noData, noDecode, noImage, badData, noPokemon
    }
    enum SortType: Int {
        case name = 0, id = 1
    }
    
    var pokemons: [Pokemon] = []
    
    //MARK: - Sorting Functions
    
    func sortBy() {
        switch UserDefaults.standard.integer(forKey: PropertyKeys.sortMethodKey) {
        case SortType.name.rawValue:
            pokemons = pokemons.sorted { $0.name < $1.name }
        default:
            pokemons = pokemons.sorted { $0.id < $1.id }
        }
        saveToPersistentStore()
    }
    
    
    // MARK: - Fetching Functions
    
    init() {
        loadFromPersistentStore()
    }
    
    func fetchPokemon(named name: String, completion: @escaping (Result<Pokemon, ErrorType>) -> Void) {
        let url = baseURL.appendingPathComponent(name)
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    completion(.failure(.badResponse))
                }
            }
            
            if let error = error {
                print("Error fetching data: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                print("No data returned from data task.")
                completion(.failure(.noData))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let decoded = try jsonDecoder.decode(Pokemon.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Unable to decode data into object of type Pokemon: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func fetchImage(for pokemon: Pokemon, completion: @escaping (Result<UIImage, ErrorType>) -> Void) {
        guard let imageURL = URL(string: pokemon.sprites.frontDefault) else {
            completion(.failure(.noImage))
            return
        }
        
        var request = URLRequest(url: imageURL)
        request.httpMethod = HTTPMethod.get
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error: \(error)")
                completion(.failure(.otherError))
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            if let index = self.pokemons.firstIndex(of: pokemon) {
                self.pokemons[index].image = data
            }
            
            if let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    // MARK: - CRUD Functions
    
    func save(pokemon: Pokemon) {
        
        if !pokemons.contains(pokemon) {
            pokemons.append(pokemon)
        }
        saveToPersistentStore()
    }
    
    func delete(_ pokemon: Pokemon) {
        guard let index = pokemons.firstIndex(of: pokemon) else { return }
        pokemons.remove(at: index)
        saveToPersistentStore()
    }
    
    // MARK: - Persistence Functions
    
    private var persistentFileURL: URL? {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return dir.appendingPathComponent("pokemon.plist")
    }
    
    private func saveToPersistentStore() {
        guard let url = persistentFileURL else { return }
        
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(pokemons)
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    private func loadFromPersistentStore() {
        let fm = FileManager.default
        guard let url = persistentFileURL,
            fm.fileExists(atPath: url.path) else { return }
        
        do{
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            pokemons = try decoder.decode([Pokemon].self, from: data)
        } catch {
            print("Error loading data: \(error)")
        }
    }
}
