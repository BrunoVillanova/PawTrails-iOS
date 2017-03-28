//
//  InitialViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, InitialView, UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var socialMediaBar: UIStackView!
    @IBOutlet weak var socialSeparator: UIImageView!
    
    fileprivate let presenter = InitialPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        emailTextField.underline()
        passwordTextField.underline()
        loginButton.round()
        signUpButton.round()
        signUpButton.border(color: UIColor.orange(), width: 1.0)
        
        cancelButton.isHidden = true
        
        if #available(iOS 10.0, *) {
            self.emailTextField.textContentType = UITextContentType.emailAddress
        }
        
        if isDebug {
            self.emailTextField.text = ezdebug.email
            self.passwordTextField.text = ezdebug.password
        }
    }
        
    @IBAction func loginAction(_ sender: UIButton?) {
        presenter.signIn(email: emailTextField.text, password:passwordTextField.text)
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        presenter.loginFB(vc: self)
    }
    
    @IBAction func googleLogin(_ sender: UIButton) {
        presenter.loginG(vc: self)
    }
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        presenter.loginTW(vc: self)
    }
    
    
    @IBAction func signUpAction(_ sender: UIButton?) {
        if cancelButton.isHidden {
            changeView(isSignUp:true)
        }else{
            presenter.signUp(email: emailTextField.text, password: passwordTextField.text)
        }
    }
    
    @IBAction func cancelSignUpAction(_ sender: UIButton) {
        changeView(isSignUp: false)
    }
    
    func changeView(isSignUp:Bool){
        
        
        UIView.animate(withDuration: 1.0, animations: {
            
            if isSignUp {
                self.loginButton.isHidden = true
                self.socialMediaBar.isHidden = true
                self.socialSeparator.isHidden = true
                let dy = self.loginButton.frame.origin.y - self.signUpButton.frame.origin.y
                self.signUpButton.transform = CGAffineTransform(translationX: 0, y: dy)
                self.signUpButton.backgroundColor = UIColor.orange()
                self.signUpButton.setTitleColor(UIColor.white, for: .normal)
            }else{
                self.signUpButton.transform = CGAffineTransform.identity
                self.signUpButton.backgroundColor = UIColor.white
                self.signUpButton.setTitleColor(UIColor.orange(), for: .normal)
                
            }
            
            self.cancelButton.isHidden = !isSignUp
            self.forgotPasswordButton.isHidden = isSignUp
            //            self.socialMediaToolBar.isHidden = isSignUp
            
        }) { (error) in
            
            if !isSignUp {
                self.loginButton.isHidden = false
                self.socialMediaBar.isHidden = false
                self.socialSeparator.isHidden = false
            }
        }
        
    }
    
    @IBAction func FBAction(_ sender: Any) {
        self.presenter.loginFB(vc: self)
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
    
    func emailFieldError(msg: String) {
        self.emailTextField.shake()
    }
    
    func passwordFieldError(msg: String) {
        self.passwordTextField.shake()
    }
    
    func loggedSocialMedia() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func verifyAccount(_ email:String) {

        if let vc = storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController {
            vc.email = email
            self.present(vc, animated: true, completion: nil)
        }
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
            if cancelButton.isHidden {
                self.loginAction(nil)
            }else{
                self.signUpAction(nil)
            }
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.underline(color: UIColor.orange())
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.underline()
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
    
}
