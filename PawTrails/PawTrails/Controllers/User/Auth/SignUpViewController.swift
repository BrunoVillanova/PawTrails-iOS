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
    
    @IBOutlet weak var agreementLabel: UILabel!
    
    
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
        
        
        let attributedString = NSMutableAttributedString(string: "By signing up,  you agree to our Terms & Conditions and Privacy Statement", attributes: [
            NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 14)!,
            NSForegroundColorAttributeName: UIColor.darkGray
            ])
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 33, length: 18))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 56, length: 17))
        
        agreementLabel.attributedText = attributedString
        
        configureNavigatonBar()
    }
    
    fileprivate func configureNavigatonBar() {
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "BackIcon"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33, height: 27)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.title = "Signup"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func configureLayout() {
        emailTextField.setLeftPaddingPoints(2)
        passwordTextField.setLeftPaddingPoints(2)
        confirmPasswordTextField.setLeftPaddingPoints(2)
        
        //emailTextField.layer.borderWidth = 0.5
        //passwordTextField.layer.borderWidth = 0.5
        //confirmPasswordTextField.layer.borderWidth = 0.5
        
        //let myColor = UIColor.groupTableViewBackground
        //emailTextField.layer.borderColor = myColor.cgColor
        //passwordTextField.layer.borderColor = myColor.cgColor
        //confirmPasswordTextField.layer.borderColor = myColor.cgColor
        
        //TEMP signUpButton.fullyroundedCorner()
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        
        //emailTextField.roundCorners(corners: [.topRight, .topLeft], radius: 10)
        //confirmPasswordTextField.roundCorners(corners: [.bottomRight, .bottomLeft], radius: 10)
    
    }

    @IBAction func signUpBtnPressed(_ sender: Any) {
        
        //TEMP
        if passwordTextField.text == confirmPasswordTextField.text  {
            self.view.endEditing(true)
            presenter.signUp(email: emailTextField.text, password: confirmPasswordTextField.text)
        } else {
            alert(title: "", msg: "Passwords don't match Please reenter passwords")
        }
        
//        let VC =   self.storyboard!.instantiateViewController(withIdentifier: "EmailVerificationViewController") as! EmailVerificationViewController
//
//        self.navigationController?.pushViewController(VC, animated: true)

       // UserDefaults.standard.set("TEST", forKey: "token") //setObject
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
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        root.selectedIndex = 0
        window?.rootViewController = root
    }
    
    func loadTutorial() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpYourDeviceVC") as! SignUpYourDeviceVC
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
        
        if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController, let pc = self.presentingViewController {
            
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




