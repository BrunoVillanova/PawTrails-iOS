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
            if let error = error {
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    self.view?.errorMessage(error.msg)
                }
            }else{
                DispatchQueue.main.async {
                    self.view?.emailSent()
                }
            }
        })
    }
    
    func checkVerification(email:String) {

        let password = ezdebug.password
        
        self.view?.beginLoadingContent()
        AuthManager.Instance.signIn(email, password) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    self.view?.errorMessage(error.msg)
                }
            }else{
                DispatchQueue.main.async {
                    self.view?.verified()
                }
            }
        }
    }
    
}
