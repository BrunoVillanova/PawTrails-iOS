//
//  NameTableViewController.swift
//  Snout
//
//  Created by Marc Perello on 22/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class NameTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    var parentEditor: EditProfilePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        nameTextField.text = parentEditor.getName()
        surnameTextField.text = parentEditor.getSurName()
        
        if #available(iOS 10.0, *) {
            nameTextField.textContentType = UITextContentType.name
            surnameTextField.textContentType = UITextContentType.familyName
        }
        
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem?) {
        parentEditor.set(name: nameTextField.text)
        parentEditor.set(surname: surnameTextField.text)
        parentEditor.refresh()
        view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.nameTextField {
            self.surnameTextField.becomeFirstResponder()
        }else if textField == self.surnameTextField {
            self.saveAction(nil)
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
