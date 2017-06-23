//
//  EmailVerificationPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 27/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol EmailVerificationView: NSObjectProtocol, View, LoadingView {
    func emailSent()
    func verified()
}

class EmailVerificationPresenter {
    
    weak fileprivate var view: EmailVerificationView?

    func attachView(_ view: EmailVerificationView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func sendVerificationEmail(email:String) {
        
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
    
    func checkVerification(email:String, password: String) {
        
        self.view?.beginLoadingContent()
        AuthManager.Instance.signIn(email, password) { (error) in
            DispatchQueue.main.async {
                self.view?.endLoadingContent()
                if let error = error {
                    
                    self.view?.errorMessage(error.msg)
                }else{
                    self.view?.verified()
                }
            }
        }
    }
    
}
