//
//  ChangePasswordPresenter.swift
//  Snout
//
//  Created by Marc Perello on 10/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum changePwdField {
    case password, newPassword, newPassword2
}

protocol ChangePasswordView: NSObjectProtocol, View {
    func emptyField(_ kind:changePwdField)
    func wrongOldPassword()
    func weakNewPassword()
    func noMatch()
    func passwordChanged()
}

class ChangePasswordPresenter {
    
    
    weak fileprivate var view: ChangePasswordView?
    fileprivate var userEmail:String!
    
    func attachView(_ view: ChangePasswordView){
        self.view = view
        DataManager.Instance.getUser(callback: { (error, user) in
            if error == nil && user != nil {
                self.userEmail = user!.email!
            }
        })
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func changePassword(password:String, newPassword:String, newPassword2:String) {
        
        if password == "" {
            self.view?.emptyField(.password)
        }else if newPassword == "" {
            self.view?.emptyField(.newPassword)
        }else if !newPassword.isValidPassword {
            self.view?.weakNewPassword()
        }else if newPassword2 == "" {
            self.view?.emptyField(.newPassword2)
        }else if newPassword != newPassword2 {
            self.view?.noMatch()
        }else{
            AuthManager.Instance.changeUsersPassword(userEmail, password, newPassword, completition: { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self.view?.errorMessage(error!)
                    }else{
                        self.view?.passwordChanged()
                    }
                }
            })
        }
    }
}
