//
//  RegisterViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, RegisterView, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    fileprivate let presenter = RegisterPresenter()
    fileprivate var notifier:Notifier!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        self.notifier = Notifier(with: self.view)
        self.emailTextField.becomeFirstResponder()
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        register()
    }
    
    func register(){
        presenter.register(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - RegisterView

    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userCreated() {
        self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    func emailFieldError(msg: String) {
        self.emailTextField.shake()
    }
    
    func passwordFieldError(msg: String) {
        self.passwordTextField.shake()
    }
    
    // MARK: - Connection Notifications
        
    func connectedToNetwork() {
        self.notifier.connectedToNetwork()
    }
    
    func notConnectedToNetwork() {
        self.notifier.notConnectedToNetwork()
    }

    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }else if textField == self.passwordTextField {
            self.register()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
