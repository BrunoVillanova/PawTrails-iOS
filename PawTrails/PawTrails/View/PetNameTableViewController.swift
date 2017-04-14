//
//  PetNameTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetNameTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    var parentEditor: AddPetPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = parentEditor.getName()
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        parentEditor.set(name: nameTextField.text)
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
}
