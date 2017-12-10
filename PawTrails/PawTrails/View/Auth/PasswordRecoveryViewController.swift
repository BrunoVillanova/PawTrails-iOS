//
//  PasswordRecoveryViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PasswordRecoveryViewController: UIViewController, PasswordRecoveryView, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!

    fileprivate let unchecked = " ⃝"
    fileprivate let checked = "◉"
    
    var email:String?
    
    fileprivate let presenter = PasswordRecoveryPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        checkButton.setTitle(unchecked, for: .normal)
        checkButton.tintColor = UIColor.primary
        emailTextField.underline()
        sendButton.round()
        sendButton.tintColor = UIColor.secondary
        sendButton.backgroundColor = UIColor.primary
        cancelButton.tintColor = UIColor.primary

        
        emailTextField.setLeftPaddingPoints(5)
        if email != nil {
            emailTextField.text = email
        }else{
            emailTextField.becomeFirstResponder()
        }
        
        if #available(iOS 10.0, *) {
            self.emailTextField.textContentType = UITextContentType.emailAddress
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    @IBAction func checkAction(_ sender: UIButton) {
        if sender.titleLabel?.text == unchecked {
            sender.setTitle(checked, for: .normal)
        }else{
            sender.setTitle(unchecked, for: .normal)
        }
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        self.presenter.sendRecoveryEmail(email: self.emailTextField.text ?? "", checked: checkButton.titleLabel?.text == checked)
    }

    // MARK: - PasswordRecoveryView
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func emailFieldError() {
        self.emailTextField.shake()
    }
    
    func emailNotChecked() {
        self.checkButton.shake()
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
