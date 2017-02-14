//
//  PasswordRecoveryPresenter.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PasswordRecoveryView: NSObjectProtocol, View {
    func emailFieldError()
    func emailNotChecked()
    func emailSent()
}

class PasswordRecoveryPresenter {
    
    weak fileprivate var passwordRecoveryView: PasswordRecoveryView?
    
    func attachView(_ view: PasswordRecoveryView){
        self.passwordRecoveryView = view
    }
    
    func deteachView() {
        self.passwordRecoveryView = nil
    }
    
    func sendRecoveryEmail(email:String, checked: Bool) {
        if email.isValidEmail {
            if checked {
                self.passwordRecoveryView?.emailSent()
            }else{
                self.passwordRecoveryView?.emailNotChecked()
            }
        }else{
            self.passwordRecoveryView?.emailFieldError()
        }
    }

}
