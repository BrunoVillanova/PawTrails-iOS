//
//  ChangePasswordViewController.swift
//  Snout
//
//  Created by Marc Perello on 10/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, ChangePasswordView, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var oldPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordLabel: UILabel!
    
    fileprivate let presenter = ChangePasswordPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        self.oldPasswordLabel.isHidden = true
        self.newPasswordLabel.isHidden = true
        self.emailTextField.becomeFirstResponder()
    }

    @IBAction func passwordViewAction(_ sender: UIButton) {
        self.passwordTextField.isSecureTextEntry = false
    }
    
    @IBAction func passwordHideAction(_ sender: UIButton) {
        self.passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func newPasswordViewAction(_ sender: UIButton) {
        self.newPasswordTextField.isSecureTextEntry = false
    }
    
    @IBAction func newPasswordHideAction(_ sender: UIButton) {
        self.newPasswordTextField.isSecureTextEntry = false
    }
    
    @IBAction func changeAction(_ sender: UIButton) {
        change()
    }
    
    func change(){
        self.oldPasswordLabel.isHidden = true
        self.newPasswordLabel.isHidden = true
        self.presenter.changePassword(email: emailTextField.text ?? "", password: passwordTextField.text ?? "", newPassword: newPasswordTextField.text ?? "")
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - CLLocationManagerDelegate

    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func emailFieldError() {
        emailTextField.shake()
    }

    func wrongOldPassword() {
        defer {
            self.oldPasswordLabel.isHidden = false
        }
        passwordTextField.shake()
    }
    
    func weakNewPassword() {
        defer {
            self.newPasswordLabel.isHidden = false
        }
        newPasswordTextField.shake()
    }
    
    func passwordChanged() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField {
            newPasswordTextField.becomeFirstResponder()
        }else if textField == newPasswordTextField {
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
