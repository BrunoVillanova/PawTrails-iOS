//
//  GenderTableViewController.swift
//  Snout
//
//  Created by Marc Perello on 22/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class GenderTableViewController: UITableViewController {
    
    var parentEditor: EditProfilePresenter!

    fileprivate var selected: Gender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        selected = parentEditor.getGender()
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        parentEditor.set(gender: selected)
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Gender.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let rowGender = Gender(rawValue: indexPath.row)
        cell.textLabel?.text = rowGender?.printName
        if selected != nil && rowGender == selected {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newSelected = Gender(rawValue: indexPath.row)
        selected = newSelected == selected ? nil : newSelected
        tableView.reloadData()
    }
}
