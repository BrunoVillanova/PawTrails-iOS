//
//  PasswordRecoveryViewController.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PasswordRecoveryViewController: UIViewController, PasswordRecoveryView, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    
    fileprivate let unchecked = " ⃝"
    fileprivate let checked = "◉"
    
    var email:String?
    
    fileprivate let presenter = PasswordRecoveryPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        self.checkButton.setTitle(unchecked, for: .normal)
        if email != nil {
            self.emailTextField.text = email
        }else{
            self.emailTextField.becomeFirstResponder()
        }
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
    @IBAction func cancelAction(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - PasswordRecoveryView
    
    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func emailFieldError() {
        self.emailTextField.shake()
    }
    
    func emailNotChecked() {
        self.checkButton.shake()
    }
    
    func emailSent() {
        let alert = UIAlertController(title: "Recovery email sent", message: "Check your email and recover your password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
