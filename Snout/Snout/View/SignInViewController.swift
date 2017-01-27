//
//  SignInViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    fileprivate let presenter = SignInPresenter()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        if isDebug {
            self.emailTextField.text = "test@try.com"
            self.passwordTextField.text = "123456"
        }
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        self.presenter.signIn(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignInViewController: SignInView {
    
    func errorMessage(_ error: String) {
        self.alert(title: "Error", msg: error)
    }
    
    func userSignedIn() {
        self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
