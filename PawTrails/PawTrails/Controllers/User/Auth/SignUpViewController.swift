//
//  SignUpViewController.swift
//  PawTrails
//
//  Created by Mohamed Ali on 01/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import SCLAlertView

class SignUpViewController: UIViewController, InitialView {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var termsAndCondButton: UIButton!
    
    
    fileprivate let presenter = InitialPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    fileprivate func initialize() {
        presenter.attachView(self)
        configureLayout()
        #if DEBUG
        emailTextField.text = "pttest13@mailinator.com"
        passwordTextField.text = "Trails111"
        confirmPasswordTextField.text = passwordTextField.text
        #endif
    }
    
    fileprivate func configureLayout() {
        emailTextField.setLeftPaddingPoints(5)
        passwordTextField.setLeftPaddingPoints(5)
        confirmPasswordTextField.setLeftPaddingPoints(5)
        
        emailTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderWidth = 0.5
        confirmPasswordTextField.layer.borderWidth = 0.5
        
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


    
    // MARK: - Initial View
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userAuthenticated() {
        SocketIOManager.instance.connect()
        let tutorialShowen = UserDefaults.standard
        
        if !tutorialShowen.bool(forKey: "tutorialShowen") {
            loadTutorial()
            
        } else {
            loadHomeScreen()
        }
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadHomeScreen() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        let root = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        root.selectedIndex = 0
        window?.rootViewController = root
    }
    
    func loadTutorial() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        let root = storyboard?.instantiateViewController(withIdentifier: "SignUpYourDeviceVC") as! SignUpYourDeviceVC
        window?.rootViewController = root
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
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController, let pc = self.presentingViewController {
            
            vc.email = email
            vc.password = password

            self.dismiss(animated: true, completion: {
                pc.present(vc, animated: true, completion: nil)
            })
        }
    }
    
    func showSuccessMessage() {
        self.showMessage("Please, confirm your e-mail address before login", type: .info)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passwordRecovery" && (self.emailTextField.text?.isValidEmail)! {
            let vc = segue.destination as! PasswordRecoveryViewController
            vc.email = self.emailTextField.text
        }
    }
}




