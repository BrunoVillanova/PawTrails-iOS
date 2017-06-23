//
//  PasswordRecoveryPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PasswordRecoveryView: NSObjectProtocol, View, LoadingView {
    func emailFieldError()
    func emailNotChecked()
    func emailSent()
}

class PasswordRecoveryPresenter {
    
    weak fileprivate var view: PasswordRecoveryView?
    
    func attachView(_ view: PasswordRecoveryView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func sendRecoveryEmail(email:String, checked: Bool) {
        
        if !email.isValidEmail {
            self.view?.emailFieldError()
        }else if !checked {
            self.view?.emailNotChecked()
        }else{
            self.view?.beginLoadingContent()
            AuthManager.Instance.sendPasswordReset(email, completition: { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.emailSent()
                    }
                }
            })
        }
    }
}
