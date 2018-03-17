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
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    
    fileprivate let presenter = EmailVerificationPresenter()
    
    var email:String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalize()
    }

    deinit {
        presenter.deteachView()
    }
    
    fileprivate func initalize() {
        presenter.attachView(self)
        configureLayout()
        emailLabel.text = email
    }
    
    fileprivate func configureLayout() {
        resendEmailButton.round()
        resendEmailButton.tintColor = UIColor.secondary
        resendEmailButton.backgroundColor = UIColor.primary
        checkButton.round()
        checkButton.tintColor = UIColor.secondary
        checkButton.backgroundColor = UIColor.primary
        signOutButton.round()
        signOutButton.tintColor = UIColor.primary
        signOutButton.border(color: UIColor.primary, width: 1.0)
    }
    
    fileprivate func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    @IBAction func checkAction(_ sender: UIButton) {
        presenter.checkVerification(email: email, password: password)
    }

    @IBAction func sendEmailAgainAction(_ sender: UIButton) {
        presenter.sendVerificationEmail(email: email)
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        dismissViewController()
    }
    
    // MARK:- EmailVerificationView
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
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
        guard let window = UIApplication.shared.delegate?.window else { return }
        guard let root = storyboard?.instantiateViewController(withIdentifier: "tabBarController") else { return }
        
        window?.rootViewController = root

        self.dismiss(animated: true) {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
