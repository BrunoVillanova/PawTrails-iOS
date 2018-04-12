//
//  EmailVerificationViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 27/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EmailVerificationViewController: UIViewController, EmailVerificationView {

    @IBOutlet weak var resendEmailButton: UIButton!
    //@IBOutlet weak var checkButton: UIButton!
    //@IBOutlet weak var signOutButton: UIButton!
    //@IBOutlet weak var emailLabel: UILabel!
    
    fileprivate let presenter = EmailVerificationPresenter()
    
    var email:String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        presenter.deteachView()
    }
    
    fileprivate func initalize() {
        presenter.attachView(self)
        configureLayout()
        //TEMP emailLabel.text = email
    }
    
    fileprivate func configureLayout() {
        
        self.navigationController?.navigationBar.isHidden = true
        //TEMP resendEmailButton.round()
        //TEMP resendEmailButton.tintColor = UIColor.secondary
        //TEMP resendEmailButton.backgroundColor = UIColor.primary
        //TEMP checkButton.round()
        //TEMP checkButton.tintColor = UIColor.secondary
        //TEMP checkButton.backgroundColor = UIColor.primary
        //TEMP signOutButton.round()
        //TEMP signOutButton.tintColor = UIColor.primary
        //TEMP signOutButton.border(color: UIColor.primary, width: 1.0)
    }
    
    fileprivate func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    @IBAction func checkAction(_ sender: UIButton) {
        presenter.checkVerification(email: email, password: password)
    }

    @IBAction func sendEmailAgainAction(_ sender: UIButton) {
        
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            presenter.sendVerificationEmail(email: userEmail)
        }
        
    }
    
    @IBAction func goBackToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        //dismissViewController()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- EmailVerificationView
    
    func errorMessage(_ error: ErrorMsg) {
        //self.alert(title: error.title, msg: error.msg)
        
        showAlert(title: error.title, infoText: error.msg)
    }
    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        hideLoadingView()
    }
    
    func emailSent() {
        hideLoadingView(with: true)
    }
    
    func verified() {
        
        //TODO remove this.ok
        if isBetaDemo {
            SignUpYourDeviceVC.userDefaults.set(false, forKey: SignUpYourDeviceVC.tutorialShownUserPreferecesKey)
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loadHomeScreen(animated: false)

        self.dismiss(animated: true) {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func showAlert(title:String,infoText:String) {
        
        let alertView = PTAlertViewController(title, infoText: infoText, buttonTypes: [AlertButtontType.ok], titleBarStyle: .red, alertResult: {alert, result in
            if result == .ok {
                alert.dismiss()
            }
        })
        
        self.present(alertView, animated: false, completion: nil)
    }
    
}
