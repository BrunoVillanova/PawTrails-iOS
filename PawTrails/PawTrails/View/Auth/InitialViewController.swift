//
//  InitialViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, InitialView, UITextFieldDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var socialMediaBar: UIStackView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    
    fileprivate let presenter = InitialPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
       
        
        loginButton.fullyroundedCorner()
        
        loginButton.backgroundColor = UIColor.primary
        loginButton.tintColor = UIColor.secondary
        
        facebookButton.fullyroundedCorner()
        facebookButton.tintColor = UIColor.primary
        facebookButton.border(color: UIColor.primary, width: 1.0)

        
        forgotPasswordButton.tintColor = UIColor.primary
        logoImageView.tintColor = UIColor.primary
        googleButton.imageView?.tintColor = UIColor.primary
        twitterButton.imageView?.tintColor = UIColor.primary
        
       
        
        if #available(iOS 10.0, *) {
            self.emailTextField.textContentType = UITextContentType.emailAddress
        }
        
        if isDebug {
            self.emailTextField.text = ezdebug.email
            self.passwordTextField.text = ezdebug.password
        }
        
        setTopBar(alpha: 1.0)

        GIDSignIn.sharedInstance().uiDelegate = self
        DispatchQueue.main.async {

        }
    }
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func loginAction(_ sender: UIButton?) {
        self.view.endEditing(true)
        presenter.signIn(email: emailTextField.text, password:passwordTextField.text)
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        UIApplication.shared.statusBarStyle = .default
        presenter.loginFB(vc: self)
    }
    
    @IBAction func googleLogin(_ sender: UIButton) {
        UIApplication.shared.statusBarStyle = .default
        presenter.loginG()
    }
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        presenter.loginTW(vc: self)
    }
    
    
    // MARK: - Initial View
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userAuthenticated() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        guard let root = storyboard?.instantiateViewController(withIdentifier: "tabBarController") else { return }
        
        window?.rootViewController = root
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
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

        if let vc = storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController {
            vc.email = email
            vc.password = password
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func successGoogleLogin(token:String){
        presenter.successGLogin(token: token)
    }
    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        hideLoadingView()
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }else if textField == self.passwordTextField {
            textField.resignFirstResponder()
                    }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.underline(color: UIColor.primary)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.underline()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passwordRecovery" && (self.emailTextField.text?.isValidEmail)! {
            let vc = segue.destination as! PasswordRecoveryViewController
            vc.email = self.emailTextField.text
        }
    }
    
    // MARK:- GIDSignInUIDelegate   

}
