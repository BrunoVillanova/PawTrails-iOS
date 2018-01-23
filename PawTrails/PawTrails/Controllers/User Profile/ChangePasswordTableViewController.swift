//
//  ChangePasswordViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 10/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class ChangePasswordTableViewController: UITableViewController, ChangePasswordView, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPassword2TextField: UITextField!
    
    fileprivate let presenter = ChangePasswordPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        self.passwordTextField.becomeFirstResponder()
    }
    
    
    
    deinit {
        self.presenter.deteachView()
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        change()
    }
    
    func change(){
        self.presenter.changePassword(password: passwordTextField.text ?? "", newPassword: newPasswordTextField.text ?? "", newPassword2: newPassword2TextField.text ?? "")
    }
    
    // MARK: - CLLocationManagerDelegate

    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }

    func emptyField(_ kind: changePwdField) {
        switch kind {
        case .password: self.passwordTextField.shake()
            break
        case .newPassword: self.newPasswordTextField.shake()
            break
        case .newPassword2: self.newPassword2TextField.shake()
            break
        }
    }
    
    func weakNewPassword() {
//        self.newPasswordLabel.isHidden = false
    }
    
    func noMatch() {
        newPassword2TextField.shake()
    }
    
    func passwordChanged() {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 1 ? Message.instance.get(.passwordRequirements) : nil
    }
    

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordTextField {
            checkmark(textField, condition: (textField.text != nil && textField.text!.isValidPassword))
            newPasswordTextField.becomeFirstResponder()
        }else if textField == newPasswordTextField {
            checkmark(textField, condition: (textField.text != nil && textField.text!.isValidPassword))
            newPassword2TextField.becomeFirstResponder()
        }else if textField == newPassword2TextField {
            checkmark(textField, condition: (newPasswordTextField.text != nil && newPassword2TextField.text != nil && newPasswordTextField.text == newPassword2TextField.text))
            if newPasswordTextField.text != nil && newPassword2TextField.text != nil && newPasswordTextField.text == newPassword2TextField.text {
                change()
            }else{
                newPassword2TextField.shake()
            }
            
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func checkmark(_ textField: UITextField, condition: Bool){
        
//        if condition, let cell = textField.superview?.superview as? UITableViewCell {
//            cell.accessoryType = UITableViewCellAccessoryType.checkmark
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
