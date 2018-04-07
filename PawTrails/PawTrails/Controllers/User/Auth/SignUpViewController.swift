//
//  SignUpViewController.swift
//  PawTrails
//
//  Created by Mohamed Ali on 01/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import SCLAlertView

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termsAndCondButton: UIButton!
    @IBOutlet weak var agreementLabel: UILabel!
    
    fileprivate final var textFields: [UITextField]?
    fileprivate let presenter = InitialPresenter()
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passwordRecovery" && (self.emailTextField.text?.isValidEmail)! {
            let vc = segue.destination as! PasswordRecoveryViewController
            vc.email = self.emailTextField.text
        }
    }
    
    fileprivate func initialize() {
        textFields = [emailTextField, passwordTextField, confirmPasswordTextField]
        
        for textField in textFields! {
            textField.delegate = self
        }
        
        presenter.attachView(self)
        configureLayout()
        #if DEBUG
        emailTextField.text = "pttest13@mailinator.com"
        passwordTextField.text = "Trails111"
        confirmPasswordTextField.text = passwordTextField.text
        #endif
        
        
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
        
        configureNavigatonBar()
    }
    
    fileprivate func configureNavigatonBar() {
        
        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(closeButtonTapped))
            self.navigationItem.rightBarButtonItem = closeButton
            self.navigationItem.rightBarButtonItem?.tintColor = PTConstants.colors.darkGray
        }
        
        self.title = "Signup"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func configureLayout() {
        emailTextField.setLeftPaddingPoints(2)
        passwordTextField.setLeftPaddingPoints(2)
        confirmPasswordTextField.setLeftPaddingPoints(2)
    }

    // MARK: - Initial View
    
    func loadHomeScreen() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        root.selectedIndex = 0
        window?.rootViewController = root
    }
    
    func loadTutorial() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpYourDeviceVC") as! SignUpYourDeviceVC
        window?.rootViewController = root
    }
    

    @IBAction func signUpBtnPressed(_ sender: Any) {
        
        //TEMP
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
}

extension SignUpViewController: InitialView {
    
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
        self.dismiss(animated: true) {
            self.appDelegate.presentViewController(.login, animated: false) {
                self.appDelegate.presentViewController(.emailVerification, animated: true, completion: nil)
            }
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
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        if let textFields = textFields, let textFieldIndex = textFields.index(of: textField), textFieldIndex < textFields.count-1 {
            let nextTextField =  textFields[textFieldIndex+1]
            nextTextField.becomeFirstResponder()
        } else {
            signUpBtnPressed(signUpButton)
        }
        
        return true
    }
}

