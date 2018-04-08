//
//  InitialViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import SCLAlertView

class InitialViewController: UIViewController {


    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var agreementLabel: UILabel!
    
    fileprivate let presenter = InitialPresenter()
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isFirstTimeViewAppears = true
    var presentEmailValidation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
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
            
            if presentEmailValidation {
                presentEmailValidation = false
                appDelegate.presentViewController(.emailVerification, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    fileprivate func initialize() {
        SocketIOManager.instance.disconnect()
        
        presenter.attachView(self)
        logoImageView.tintColor = UIColor.primary
        
        let attributedString = NSMutableAttributedString(string: "By signing up,  you agree to our Terms & Conditions and Privacy Statement", attributes: [
            NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 13)!,
            NSForegroundColorAttributeName: UIColor.darkGray
            ])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 6
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 33, length: 18))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 56, length: 17))
        
        agreementLabel.attributedText = attributedString
    }
    

    @IBAction func signupAction(_ sender: Any) {
        appDelegate.presentViewController(.signup, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: UIButton?) {
        appDelegate.presentViewController(.login, animated: true, completion: nil)
    }
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        UIApplication.shared.statusBarStyle = .default
        presenter.loginFB(vc: self)
    }
    
    @IBAction func termsAndPrivacyAction(_ sender: Any) {
        appDelegate.presentViewController(.termsAndPrivacy, animated: true, completion: nil)
    }
    
}

extension InitialViewController: InitialView {
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
