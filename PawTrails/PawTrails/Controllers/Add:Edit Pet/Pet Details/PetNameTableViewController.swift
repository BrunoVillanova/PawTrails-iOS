//
//  PetNameTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetNameTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    var parentEditor: AddEditPetPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = parentEditor.pet.name
        nameTextField.becomeFirstResponder()
        nameTextField.delegate = self
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        parentEditor.pet.name = nameTextField.text
        parentEditor.refresh()
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.nameTextField {
            doneAction(nil)
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
