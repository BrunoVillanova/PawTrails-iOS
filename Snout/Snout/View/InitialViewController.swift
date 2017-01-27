//
//  InitialViewController.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import GoogleSignIn

class InitialViewController: UIViewController, GIDSignInUIDelegate {

    fileprivate let presenter = InitialPresenter()
    
    var signInButton: GIDSignInButton!

    fileprivate let buttonWidth: CGFloat = 200.0
    fileprivate let buttonHeight: CGFloat = 40.0
    fileprivate let buttonY: CGFloat = 40.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        GIDSignIn.sharedInstance().uiDelegate = self
        
        signInButton = GIDSignInButton(frame: CGRect(x: self.view.center.x - CGFloat(self.buttonWidth/2.0), y: self.view.center.y + buttonY, width: buttonWidth, height: buttonHeight))
        self.view.addSubview(signInButton)
    }

}

extension InitialViewController: InitialView {
    
    func errorMessage(_ error: String) {
        self.alert(title: "Warning", msg: error)
    }
    
}
