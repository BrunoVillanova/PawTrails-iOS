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

//    @IBOutlet weak var emailTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var forgotPasswordButton: UIButton!
//    @IBOutlet weak var loginButton: UIButton!
    //@IBOutlet weak var signUpButton: UIButton!
    //@IBOutlet weak var socialMediaBar: UIStackView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
    //@IBOutlet weak var googleButton: UIButton!
    //@IBOutlet weak var twitterButton: UIButton!
    
    //V2
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var agreementLabel: UILabel!
    
    fileprivate let presenter = InitialPresenter()
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isFirstTimeViewAppears = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.instance.disconnect()
        
        //TEMP
        
        //TEMP emailTextField.setLeftPaddingPoints(5)
        //TEMP passwordTextField.setLeftPaddingPoints(5)
        
        self.view.isUserInteractionEnabled = true

        presenter.attachView(self)

        //TEMP loginButton.fullyroundedCorner()
        
        //TEMP loginButton.backgroundColor = UIColor.primary
        //TEMP loginButton.tintColor = UIColor.secondary
        
        //TEMP facebookButton.fullyroundedCorner()
        //TEMP facebookButton.tintColor = UIColor.primary
        //TEMP facebookButton.border(color: UIColor.primary, width: 1.0)

        
        //TEMP forgotPasswordButton.tintColor = UIColor.primary
        logoImageView.tintColor = UIColor.primary
        //TEMP googleButton.imageView?.tintColor = UIColor.primary
        //TEMP twitterButton.imageView?.tintColor = UIColor.primary
        
        
       
        let attributedString = NSMutableAttributedString(string: "By signing up,  you agree to our Terms & Conditions and Privacy Statement", attributes: [
            NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 14)!,
            NSForegroundColorAttributeName: UIColor.darkGray
            ])
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 33, length: 18))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 56, length: 17))
        
       agreementLabel.attributedText = attributedString
        
        if #available(iOS 10.0, *) {
            //TEMP self.emailTextField.textContentType = UITextContentType.emailAddress
        }
        
        
        #if !RELEASE
            //TEMP self.emailTextField.text = Constants.testUserEmail
            //TEMP self.passwordTextField.text = Constants.testUserPassword
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTimeViewAppears {
            isFirstTimeViewAppears = false
            appDelegate.showOnboardingIfNeeded(false)
        }
    }
    
    @IBAction func signupAction(_ sender: UIButton?) {
        UIApplication.shared.statusBarStyle = .default
        self.view.endEditing(true)
        //TEMP presenter.signIn(email: emailTextField.text, password:passwordTextField.text)
        
    }

    
    @IBAction func loginAction(_ sender: UIButton?) {
        UIApplication.shared.statusBarStyle = .default
        self.view.endEditing(true)
        //TEMP presenter.signIn(email: emailTextField.text, password:passwordTextField.text)
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
        //TEMP self.emailTextField.shake()
    }
    
    func passwordFieldError() {
        //TEMP self.passwordTextField.shake()
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
        //TEMP
//        if textField == self.emailTextField {
//            self.passwordTextField.becomeFirstResponder()
//        }else if textField == self.passwordTextField {
//            textField.resignFirstResponder()
//                    }else{
//            textField.resignFirstResponder()
//        }
        return true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TEMP
//        if segue.identifier == "passwordRecovery" && (self.emailTextField.text?.isValidEmail)! {
//            let vc = segue.destination as! PasswordRecoveryViewController
//            vc.email = self.emailTextField.text
//        }
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
