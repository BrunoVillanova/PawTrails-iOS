//
//  SignUpViewController.swift
//  PawTrails
//
//  Created by Mohamed Ali on 01/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, InitialView {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var termsAndCondButton: UIButton!
    
    
    fileprivate let presenter = InitialPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        confirmPasswordTextField.layer.borderWidth = 0.5
//
      
        
        let myColor = UIColor.groupTableViewBackground
        emailTextField.layer.borderColor = myColor.cgColor
        passwordTextField.layer.borderColor = myColor.cgColor
        confirmPasswordTextField.layer.borderColor = myColor.cgColor
        
        
        signUpButton.fullyroundedCorner()


    }
    
    
    override func viewDidLayoutSubviews() {
        
        emailTextField.roundCorners(corners: [.topRight, .topLeft], radius: 10)
        confirmPasswordTextField.roundCorners(corners: [.bottomRight, .bottomLeft], radius: 10)
    
    }

    @IBAction func signUpBtnPressed(_ sender: Any) {
        
        if passwordTextField.text == confirmPasswordTextField.text  {
            
            self.view.endEditing(true)
            presenter.signUp(email: emailTextField.text, password: confirmPasswordTextField.text)
            
        } else {
            alert(title: "", msg: "Passwords don't match Please reenter passwords")
        }
    }

    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        self.confirmPasswordTextField.shake()
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

    

}




