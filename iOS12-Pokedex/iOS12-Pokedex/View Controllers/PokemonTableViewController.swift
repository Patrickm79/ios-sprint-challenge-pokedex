//
//  PokemonTableViewController.swift
//  iOS12-Pokedex
//
//  Created by Patrick Millet on 12/6/19.
//  Copyright © 2019 Patrick Millet. All rights reserved.
//

import UIKit

class PokemonTableViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var segmentedController: UISegmentedControl!

    // MARK: - Properties
    
    struct PropertyKeys {
        static let cell = "PokemonCell"
        static let addSegue = "AddPokemonSegue"
        static let detailSegue = "PokemonDetailSegue"
    }

    let pokeController = PokemonController()

    // MARK: - Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedController.selectedSegmentIndex = UserDefaults.standard.integer(forKey: PokemonController.PropertyKeys.sortMethodKey)
    }

    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        sortPokemon()
    }

    // MARK: - Actions
    
    @IBAction func sortChanged(_ sender: UISegmentedControl) {
        switch UserDefaults.standard.integer(forKey: PokemonController.PropertyKeys.sortMethodKey) {
        case 0:
            UserDefaults.standard.set(1, forKey: PokemonController.PropertyKeys.sortMethodKey)
        default:
            UserDefaults.standard.set(0, forKey: PokemonController.PropertyKeys.sortMethodKey)
        }
        sortPokemon()
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pokeController.pokemons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.cell, for: indexPath)

        cell.textLabel?.text = capitalize(pokeController.pokemons[indexPath.row].name)
        cell.detailTextLabel?.text = "ID: \(pokeController.pokemons[indexPath.row].id)"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            pokeController.delete(pokeController.pokemons[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Private
    
    private func sortPokemon() {
        pokeController.sortBy()
        tableView.reloadData()
    }

    private func capitalize(_ word: String) -> String {
        var newWord = word
        let firstLetter = newWord.startIndex
        let capFirst = newWord[firstLetter].uppercased()
        newWord.remove(at: firstLetter)
        newWord.insert(Character(capFirst), at: firstLetter)
        return newWord
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.addSegue {
            if let addVC = segue.destination as? PokemonDetailViewController {
                addVC.pokeController = pokeController
            }
        } else if segue.identifier == PropertyKeys.detailSegue {
            if let detailVC = segue.destination as? PokemonDetailViewController, let indexPath = tableView.indexPathForSelectedRow {
                detailVC.pokeController = pokeController
                detailVC.pokemon = pokeController.pokemons[indexPath.row]
            }
        }
    }
}
