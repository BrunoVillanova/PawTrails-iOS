//
//  LoginViewController.swift
//  PawTrails
//
//  Created by Abhijith on 04/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, InitialView {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    fileprivate let presenter = InitialPresenter()
    fileprivate final var textFields: [UITextField]?
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    fileprivate func initialize() {
        textFields = [emailTextField, passwordTextField]
        
        for textField in textFields! {
            textField.delegate = self
        }
        
        presenter.attachView(self)
        configureNavigatonBar()
    }
    
    fileprivate func configureNavigatonBar() {

        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(closeButtonTapped))
            self.navigationItem.rightBarButtonItem = closeButton
            self.navigationItem.rightBarButtonItem?.tintColor = PTConstants.colors.darkGray
        }

        self.title = "Login"
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
    }

    func emailFieldError() {
         self.emailTextField.shake()
    }
    
    func passwordFieldError() {
         self.passwordTextField.shake()
    }
    
    func loggedSocialMedia() {
        userAuthenticated()
    }
    
    func verifyAccount(_ email:String, _ password:String) {
        let vc = ViewControllers.emailVerification.viewController as! EmailVerificationViewController
        vc.email = email
        vc.password = password
        self.present(vc, animated: true, completion: nil)
    }
    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        hideLoadingView()
    }
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userAuthenticated() {
        self.view.endEditing(true)
    
        self.dismiss(animated: true) {
            self.appDelegate.loadHomeScreen(animated: true)
        }
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        self.appDelegate.presentViewController(.passwordRecovery, animated: true, completion: nil)
    }
    
    @IBAction func signupAction(_ sender: Any) {
        self.dismiss(animated: true) { [unowned self] in
            self.appDelegate.presentViewController(.signup, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton?) {
        UIApplication.shared.statusBarStyle = .default
        self.view.endEditing(true)
        presenter.signIn(email: emailTextField.text, password:passwordTextField.text)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let textFields = textFields, let textFieldIndex = textFields.index(of: textField), textFieldIndex < textFields.count-1 {
            let nextTextField =  textFields[textFieldIndex+1]
            nextTextField.becomeFirstResponder()
        } else {
            loginAction(loginButton)
        }
        
        return true
    }
}
