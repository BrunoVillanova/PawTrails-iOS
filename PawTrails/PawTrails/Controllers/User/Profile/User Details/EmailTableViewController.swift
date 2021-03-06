//
//  EmailTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 22/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EmailTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    var parentEditor: EditUserProfilePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        emailTextField.text = parentEditor.user.email
        if #available(iOS 10.0, *) {
            emailTextField.textContentType = UITextContentType.emailAddress
        }
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem?) {
        if emailTextField.text != nil && emailTextField.text != "" && !emailTextField.text!.isValidEmail {
            emailTextField.shake()
        }else{
            parentEditor.user.email = emailTextField.text
            parentEditor.refresh()
            view.endEditing(true)
            _ = self.navigationController?.popViewController(animated: true)
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
