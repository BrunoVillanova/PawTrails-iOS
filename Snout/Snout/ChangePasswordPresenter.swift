//
//  ChangePasswordPresenter.swift
//  Snout
//
//  Created by Marc Perello on 10/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol ChangePasswordView: NSObjectProtocol, View {
    func emailFieldError()
    func wrongOldPassword()
    func weakNewPassword()
    func passwordChanged()
}

class ChangePasswordPresenter {
    
    weak fileprivate var changePasswordView: ChangePasswordView?
    
    func attachView(_ view: ChangePasswordView){
        self.changePasswordView = view
    }
    
    func deteachView() {
        self.changePasswordView = nil
    }
    
    func changePassword(email:String, password:String, newPassword:String) {
        
        if !email.isValidEmail {
            self.changePasswordView?.emailFieldError()
        }else if !password.isValidPassword {
            self.changePasswordView?.wrongOldPassword()
        }else if !newPassword.isValidPassword {
            self.changePasswordView?.weakNewPassword()
        }else{
//            let input = ["email":email, "password":password, "newPassword":newPassword]
//            APIManager.Instance.performCall(.passwordChange, input, completition: { (error, data) in
//                //
//            })
            self.changePasswordView?.passwordChanged()
        }
 
    }
    
}
