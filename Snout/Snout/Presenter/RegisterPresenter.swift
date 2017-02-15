//
//  RegisterPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol RegisterView: NSObjectProtocol, View, ConnectionView {
    func emailFieldError(msg:String)
    func passwordFieldError(msg:String)
    func userCreated()
}

class RegisterPresenter {
    
    weak fileprivate var registerView: RegisterView?
    private var reachability: Reachbility!

    func attachView(_ view: RegisterView){
        self.registerView = view
        self.reachability = Reachbility(view)
    }
    
    func deteachView() {
        self.registerView = nil
    }
    
    func register(email:String, password:String) {
        if self.reachability.isConnected() && email.isValidEmail && password.isValidPassword {
            AuthManager.Instance.register(email, password) { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self.registerView?.errorMessage(error!)
                    }else{
                        self.registerView?.userCreated()
                    }
                }
            }
        }else if !email.isValidEmail {
            self.registerView?.emailFieldError(msg: Message.Instance.authError(type: .EmailFormat).msg)
        }else if !password.isValidPassword {
            self.registerView?.passwordFieldError(msg: Message.Instance.authError(type: .WeakPassword).msg)
        }
    }
}
