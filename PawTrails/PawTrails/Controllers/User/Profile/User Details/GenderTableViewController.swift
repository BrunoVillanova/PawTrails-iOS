//
//  GenderTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 22/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class GenderTableViewController: UITableViewController {
    
    var parentEditor: EditUserProfilePresenter!

    fileprivate var selected: Gender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        selected = parentEditor.user.gender
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        parentEditor.user.gender = selected
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
        let rowGender = Gender(rawValue: Int16(indexPath.row))
        cell.textLabel?.text = rowGender?.name
        if selected != nil && rowGender == selected {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newSelected = Gender(rawValue: Int16(indexPath.row))
        selected = newSelected?.code == selected?.code ? nil : newSelected
        tableView.reloadData()
    }
}
