//
//  PasswordRecoveryViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import GSMessages

class PasswordRecoveryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var mainView: PTLinesBackgroundView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var email:String?
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TEMP emailTextField.underline()
        emailTextField.setLeftPaddingPoints(5)
        
        //TEMP cancelButton.tintColor = UIColor.primary
        
        if email != nil {
            emailTextField.text = email
        } else {
            emailTextField.becomeFirstResponder()
        }
        
        if #available(iOS 10.0, *) {
            self.emailTextField.textContentType = UITextContentType.emailAddress
        }
        
        configureNavigatonBar()
    }
    
    fileprivate func configureNavigatonBar() {
        
        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(closeButtonTapped))
            self.navigationItem.rightBarButtonItem = closeButton
            self.navigationItem.rightBarButtonItem?.tintColor = PTConstants.colors.darkGray
        }
        
        self.title = "Forgot Password"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func closeButtonTapped() {
        self.dismissAndGoToLogin()
    }
    
    fileprivate func dismissAndGoToLogin(_ completion: (() -> Void)? = nil) {
        view.endEditing(true)
        self.dismiss(animated: true, completion: completion)
    }
    
    @IBAction func loginNowAction(_ sender: Any) {
        self.dismissAndGoToLogin()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func sendRecoveryEmail(email:String, checked: Bool) {
        
        if !email.isValidEmail {
            self.showMessage("Email is not valid!", type: GSMessageType.error)
        } else {

            self.showLoadingView()
            DataManager.instance.sendPasswordReset(email, callback: { (error) in
                
                self.hideLoadingView()
                
                if let error = error {
                    self.showMessage(error.msg.msg, type: GSMessageType.error)

                } else {
                    self.cycleViewControllers(currentViewController: self, nextViewController: ViewController.passwordRecoverySuccess.viewController)
                }
            })
        }
    }
    
    
    
    @IBAction func sendAction(_ sender: UIButton) {
        self.sendRecoveryEmail(email: self.emailTextField.text ?? "", checked: true)
    }
    
    @IBAction func signupAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.appDelegate.presentViewController(.signup, animated: true, completion: nil)
        })
    }
    
    
    // MARK: - PasswordRecoveryView
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func emailFieldError() {
        self.emailTextField.shake()
    }
    
    
    func emailSent() {
        cycleViewControllers(currentViewController: self, nextViewController: ViewController.passwordRecoverySuccess.viewController)
    }
    
    
    fileprivate func cycleViewControllers(currentViewController: UIViewController, nextViewController: UIViewController) {
        
    
        addChildViewController(nextViewController)
        
        nextViewController.view.frame = mainView.bounds
        nextViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mainView.addSubview(nextViewController.view)

        UIView.transition(from: currentViewController.view, to: nextViewController.view, duration: 0.3, options: .layoutSubviews) { (finished) in
            if finished {
                nextViewController.didMove(toParentViewController: self)
            }
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
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.underline(color: UIColor.primary)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.underline()
    }

}
