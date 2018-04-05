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
    
    //@IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    
    var email:String?
    
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
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "BackIcon"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33, height: 27)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.title = "Forgot Password"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    @IBAction func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
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
                    self.dismiss(animated: true, completion: {
                        UIApplication.shared.keyWindow?.rootViewController!.showMessage("Recovery instructions was sent to your email!", type: GSMessageType.success,  options: [
                            .animation(.slide),
                            .animationDuration(0.3),
                            .autoHide(true),
                            .cornerRadius(0.0),
                            .height(44.0),
                            .hideOnTap(true),
                            //                .margin(.init(top: 64, left: 0, bottom: 0, right: 0)),
                            //                .padding(.zero),
                            .position(.top),
                            .textAlignment(.center),
                            .textNumberOfLines(0),
                            ])
                    })
                }
            })
        }
    }
    
    
    
    @IBAction func sendAction(_ sender: UIButton) {
        self.sendRecoveryEmail(email: self.emailTextField.text ?? "", checked: true)
    }
    

    // MARK: - PasswordRecoveryView
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func emailFieldError() {
        self.emailTextField.shake()
    }
    
    
    func emailSent() {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Recovery email sent", message: "Check your email and recover your password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
