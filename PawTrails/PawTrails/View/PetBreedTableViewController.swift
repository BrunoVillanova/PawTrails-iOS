//
//  PetBreedViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetBreedViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate, PetBreedsView {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noTypeSelected: UILabel!
    
    var filteredBreeds = [Breed]()
    
    var selectedA:IndexPath?
    var selectedB:IndexPath?
    var otherBreed: String?
    
    var parentEditor: AddEditPetPresenter!
    var presenter = PetBreedsPresenter()
    
    fileprivate var type: Type?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
    
        tableView.tableFooterView = UIView()
        
        if let typeName = parentEditor.getType() {
            noTypeSelected.isHidden = true
            if let type = Type.build(code: typeName) {
                
                if type == .other {
                    searchBar.isHidden = true
                    tableView.allowsSelection = false
                }
                
                if type == .other || type == .cat {
                    segmentControl.isHidden = true
                    tableTopConstraint.constant = 0
                }
                
                self.type = type
                presenter.getBreeds(for: type)
            }
        }else{
            segmentControl.isHidden = true
            tableView.isHidden = true
            noTypeSelected.isHidden = false
        }
        
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        
        if let indexA = selectedA {
            
            if let indexB = selectedB {
                parentEditor.set(breeds: [filteredBreeds[indexA.row].name!, filteredBreeds[indexB.row].name!])
            }else{
                parentEditor.set(breeds: [filteredBreeds[indexA.row].name!])
            }
        }else if let otherBreed = otherBreed {
            parentEditor.set(breeds: [otherBreed])
        }else {
            parentEditor.set(breeds: nil)
        }
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        
        if let indexA = selectedA {
            if let indexB = selectedB {
                tableView.reloadRows(at: [indexA, indexB], with: .automatic)
            }else{
                tableView.reloadRows(at: [indexA], with: .automatic)
            }
        }
        
    }
    
    // MARK: - PetBreedsView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func loadBreeds() {
        filteredBreeds = presenter.breeds
        
        if let breeds = parentEditor.getBreeds() {
            
            if 1...2 ~= breeds.count {
                
                if let index = filteredBreeds.index(where: { $0.name == breeds[0] }) {
                    selectedA = IndexPath(row: index, section: 0)
                }
                
                if breeds.count == 2, let index = filteredBreeds.index(where: { $0.name == breeds[1] }) {
                    selectedB = IndexPath(row: index, section: 0)
                    segmentControl.selectedSegmentIndex = 1
                }
            }
        }
        tableView.reloadData()
        
        if let selectedA = selectedA {
            tableView.scrollToRow(at: selectedA, at: .middle, animated: true)
        }

    }
    
    func breedsNotFound() {
        alert(title: "", msg: "Couldn't find breeds")
    }
    
    // MARK: - TableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (type != nil && type == .other) ? 1 : filteredBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (type != nil) && type == .other {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellOther", for: indexPath) as! otherBreedCell
            cell.breedTextField.delegate = self
            cell.breedTextField.becomeFirstResponder()
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let breed = filteredBreeds[indexPath.row]
            cell.textLabel?.text = breed.name

            if segmentControl.selectedSegmentIndex == 0 {
                if indexPath == selectedA {
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
            }else{
                if indexPath == selectedA || indexPath == selectedB {
                    cell.accessoryType = .checkmark
                }else{
                    cell.accessoryType = .none
                }
            }
            return cell
        }
    }

    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if type != nil && type != .other {
            var indexes = [indexPath]
            
            if let selA = selectedA { indexes.append(selA) }
            if let selB = selectedB { indexes.append(selB) }
            
            indexes.append(indexPath)
            
            if segmentControl.selectedSegmentIndex == 0 {
                if indexPath == selectedA {
                    selectedA = nil
                }else{
                    selectedA = indexPath
                }
            }else{
                if indexPath == selectedA {
                    if selectedB != nil {
                        selectedA = selectedB
                        selectedB = nil
                    }else{
                        selectedA = nil
                    }
                }else if indexPath == selectedB {
                    selectedB = nil
                }else{
                    if selectedA == nil {
                        selectedA = indexPath
                    }else{
                        selectedB = indexPath
                    }
                }
            }
            tableView.reloadRows(at: indexes, with: .fade)
        }
    }


    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredBreeds.removeAll(keepingCapacity: true)
        if searchText != "" {
            for b in presenter.breeds {
                if let name = b.name, name.lowercased().contains(searchText.lowercased()) {
                    filteredBreeds.append(b)
                }
            }
        }else{
            filteredBreeds.append(contentsOf: presenter.breeds)
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
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        otherBreed = textField.text
        doneAction(nil)
        return true
    }
}

class otherBreedCell: UITableViewCell {
    @IBOutlet weak var breedTextField: UITextField!
}
