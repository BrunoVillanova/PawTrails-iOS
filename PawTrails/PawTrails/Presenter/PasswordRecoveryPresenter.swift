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
        if email.isValidEmail {
            if checked {
                self.view?.beginLoadingContent()
                AuthManager.Instance.sendPasswordReset(email, completition: { (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view?.endLoadingContent()
                            self.view?.errorMessage(error.msg)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.view?.endLoadingContent()
                            self.view?.emailSent()
                        }
                    }
                })
            }else{
                self.view?.emailNotChecked()
            }
        }else{
            self.view?.emailFieldError()
        }
    }

}
