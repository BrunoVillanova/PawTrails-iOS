//
//  PetBreedTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetBreedTableViewController: UITableViewController, UISearchBarDelegate {
    
    var breeds = [String]()
    var _breeds = [String]()
    var selected:IndexPath?
    
    var parentEditor: AddPetPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...1000 {
            _breeds.append("breed \(i)")
        }
        breeds.append(contentsOf: _breeds)
        
        if let breed = parentEditor.getBreed() {
            if let index = breeds.index(of: breed) {
                selected = IndexPath(row: index, section: 0)
                tableView.reloadData()
            }
        }
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        
        if let index = selected {
            parentEditor.set(breed: breeds[index.row])
        }else{
            parentEditor.set(breed: nil)
        }
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let breed = breeds[indexPath.row]
        cell.textLabel?.text = breed
        if indexPath == selected {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldIndex = selected
        if indexPath == selected {
            selected = nil
        }else{
            selected = indexPath
        }
        let indexes = oldIndex == nil ? [indexPath] : [indexPath, oldIndex!]
        tableView.reloadRows(at: indexes, with: .fade)
    }


    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        breeds.removeAll(keepingCapacity: true)
        if searchText != "" {
            for b in _breeds {
                if b.lowercased().contains(searchText.lowercased()) {
                    breeds.append(b)
                }
            }
        }else{
            breeds.append(contentsOf: _breeds)
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
