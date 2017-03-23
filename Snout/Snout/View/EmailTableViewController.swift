//
//  EmailTableViewController.swift
//  Snout
//
//  Created by Marc Perello on 22/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EmailTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    var parentEditor: EditProfilePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        emailTextField.text = parentEditor.getEmail()
        if #available(iOS 10.0, *) {
            emailTextField.textContentType = UITextContentType.emailAddress
        }
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem?) {
        if emailTextField.text != nil && emailTextField.text != "" && !emailTextField.text!.isValidEmail {
            emailTextField.shake()
        }else{
            parentEditor.set(email: emailTextField.text)
            self.view.endEditing(true)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.emailTextField {
            saveAction(nil)
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
