//
//  RegisterViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    fileprivate let presenter = RegisterPresenter()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        if isDebug {
            self.emailTextField.text = "test@try.com"
            self.passwordTextField.text = "123456"
        }
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        presenter.register(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RegisterViewController: RegisterView {
    
    func errorMessage(_ error: String) {
        self.alert(title: "Error", msg: error)
    }
    
    func userCreated() {
        self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
}
