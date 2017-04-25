//
//  PetGenderTableViewController.swift
//  
//
//  Created by Marc Perello on 11/04/2017.
//
//

import UIKit

class PetGenderTableViewController: UITableViewController {

    
    var parentEditor: AddEditPetPresenter!
    
    fileprivate var selected: Gender?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        selected = parentEditor.getGender()

    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        parentEditor.set(gender: selected)
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Gender.count()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let rowGender = Gender(rawValue: indexPath.row)
        cell.textLabel?.text = rowGender?.name
        if selected != nil && rowGender == selected {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    //MARK:- UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newSelected = Gender(rawValue: indexPath.row)
        selected = newSelected?.code == selected?.code ? nil : newSelected
        tableView.reloadData()
    }
}
