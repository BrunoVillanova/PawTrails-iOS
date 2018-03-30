//
//  InitialViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import SCLAlertView

class InitialViewController: UIViewController, InitialView, UITextFieldDelegate {

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
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isFirstTimeViewAppears = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.instance.disconnect()
        
        emailTextField.setLeftPaddingPoints(5)
        passwordTextField.setLeftPaddingPoints(5)
        
        self.view.isUserInteractionEnabled = true

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
        
        
        #if !RELEASE
            self.emailTextField.text = Constants.testUserEmail
            self.passwordTextField.text = Constants.testUserPassword
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTimeViewAppears {
            isFirstTimeViewAppears = false
            appDelegate.showOnboardingIfNeeded(false)
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton?) {
        UIApplication.shared.statusBarStyle = .default
        self.view.endEditing(true)
        presenter.signIn(email: emailTextField.text, password:passwordTextField.text)
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        UIApplication.shared.statusBarStyle = .default
        presenter.loginFB(vc: self)
    }
    
    @IBAction func googleLogin(_ sender: UIButton) {
    }
    
    @IBAction func twitterLogin(_ sender: UIButton) {
    }
    
    
    // MARK: - Initial View
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userAuthenticated() {
        self.view.endEditing(true)
        SocketIOManager.instance.connect()
        loadHomeScreen()
    }
    
    func loadHomeScreen() {
        guard let window = UIApplication.shared.delegate?.window else { return }

        if let currentRootViewController = window!.rootViewController {
            let root = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            root.selectedIndex = 0
            
            UIView.transition(from: currentRootViewController.view, to: root.view, duration: 0.3, options: UIViewAnimationOptions.transitionCurlUp, completion: {(finished) in
                UIApplication.shared.keyWindow?.rootViewController = root
            })
        }
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
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController {
            vc.email = email
            vc.password = password
            self.present(vc, animated: true, completion: nil)
        }
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



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
