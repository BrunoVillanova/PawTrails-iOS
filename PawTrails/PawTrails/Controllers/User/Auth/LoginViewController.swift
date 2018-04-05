//
//  LoginViewController.swift
//  PawTrails
//
//  Created by Abhijith on 04/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,InitialView {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    fileprivate let presenter = InitialPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(self)
        // Do any additional setup after loading the view.
        
        configureNavigatonBar()
    }
    
    fileprivate func configureNavigatonBar() {

        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "BackIcon"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(backButtonTapped), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33, height: 27)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.title = "Login"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func emailFieldError() {
         self.emailTextField.shake()
    }
    
    func passwordFieldError() {
         self.passwordTextField.shake()
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
            let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            root.selectedIndex = 0
            
            UIView.transition(from: currentRootViewController.view, to: root.view, duration: 0.3, options: UIViewAnimationOptions.transitionCurlUp, completion: {(finished) in
                UIApplication.shared.keyWindow?.rootViewController = root
            })
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton?) {
        UIApplication.shared.statusBarStyle = .default
        self.view.endEditing(true)
        presenter.signIn(email: emailTextField.text, password:passwordTextField.text)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //TEMP
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
