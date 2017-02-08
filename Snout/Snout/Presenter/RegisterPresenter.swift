//
//  RegisterPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol RegisterView: NSObjectProtocol, View {
    func userCreated()
}

class RegisterPresenter {
    
    weak fileprivate var registerView: RegisterView?
    
    func attachView(_ view: RegisterView){
        self.registerView = view
    }
    
    func deteachView() {
        self.registerView = nil
    }
    
    func register(email:String, password:String) {
        AuthManager.Instance.register(email, password) { (error) in
            if error != nil {
                self.registerView?.errorMessage(error!)
            }else{
                self.registerView?.userCreated()
            }
        }
    }
    
}
