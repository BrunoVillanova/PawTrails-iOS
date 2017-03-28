//
//  ChangePasswordViewController.swift
//  Snout
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
        /*if isDebug {
            self.passwordTextField.text = ezdebug.email
            self.newPasswordTextField.text = ezdebug.password + "2"
            self.newPassword2TextField.text = ezdebug.password + "2"
        }*/
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
    
    func wrongOldPassword() {
//        self.oldPasswordLabel.isHidden = false
    }
    
    func weakNewPassword() {
//        self.newPasswordLabel.isHidden = false
    }
    
    func noMatch() {
//        self.noMatchLabel.isHidden = false
    }
    
    func passwordChanged() {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordTextField {
            newPasswordTextField.becomeFirstResponder()
        }else if textField == newPasswordTextField {
            newPassword2TextField.becomeFirstResponder()
        }else if textField == newPassword2TextField {
            change()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
