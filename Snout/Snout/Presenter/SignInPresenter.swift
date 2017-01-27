//
//  SignInPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol SignInView: NSObjectProtocol {
    func errorMessage(_ error:String)
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
        FBAuthManagement.Instance.signIn(email, password) { (error) in
            if error != nil {
                self.signInView?.errorMessage(error!)
            }else{
                self.signInView?.userSignedIn()
            }
        }
    }
    
}
