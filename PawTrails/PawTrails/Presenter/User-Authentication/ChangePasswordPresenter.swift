//
//  ChangePasswordPresenter.swift
//  PawTrails
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
    func weakNewPassword()
    func noMatch()
    func passwordChanged()
}

class ChangePasswordPresenter {
    
    weak fileprivate var view: ChangePasswordView?
    
    private var userEmail:String!
    
    func attachView(_ view: ChangePasswordView){
        self.view = view
        self.getUserEmail()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getUserEmail(){
        DataManager.instance.getUser(callback: { (error, user) in
            if error == nil && user != nil {
                self.userEmail = user!.email!
            }else{
                self.view?.errorMessage(ErrorMsg.init(title: "", msg: ""))
            }
        })
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
            DataManager.instance.changeUsersPassword(userEmail, password, newPassword, callback: { (error) in
                
                if let error = error {
                    self.view?.errorMessage(error.msg)
                }else{
                    self.view?.passwordChanged()
                }
            })
        }
    }
}
