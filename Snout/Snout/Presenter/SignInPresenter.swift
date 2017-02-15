//
//  SignInPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol SignInView: NSObjectProtocol, View, ConnectionView {
    func emailFieldError(msg:String)
    func passwordFieldError(msg:String)
    func userSignedIn()
}

class SignInPresenter {
    
    weak private var signInView: SignInView?
    private var reachability: Reachbility!
    
    func attachView(_ view: SignInView){
        self.signInView = view
        self.reachability = Reachbility(view)
    }
    
    func deteachView() {
        self.signInView = nil
    }

    func signIn(email:String, password:String) {
        if self.reachability.isConnected() && email.isValidEmail && password.isValidPassword {
            AuthManager.Instance.signIn(email, password) { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self.signInView?.errorMessage(error!)
                    }else{
                        self.signInView?.userSignedIn()
                    }
                }
            }
        }else if !email.isValidEmail {
            self.signInView?.emailFieldError(msg: Message.Instance.authError(type: .EmailFormat).msg)
        }else if !password.isValidPassword {
            self.signInView?.passwordFieldError(msg: Message.Instance.authError(type: .WeakPassword).msg)
        }
    }
}
