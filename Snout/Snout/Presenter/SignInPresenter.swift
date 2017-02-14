//
//  SignInPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol SignInView: NSObjectProtocol, View {
    func emailFieldError(msg:String)
    func passwordFieldError(msg:String)
    func userSignedIn()
}

class SignInPresenter {
    
    weak fileprivate var signInView: SignInView?
    
    func attachView(_ view: SignInView){
        self.signInView = view
    }
    
    func deteachView() {
        self.signInView = nil
    }
    
    func signIn(email:String, password:String) {
        if email.isValidEmail && password.isValidPassword {
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
