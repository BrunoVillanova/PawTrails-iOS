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
        DataManager.instance.sendPasswordReset(email, callback: { (error) in
            
            self.view?.endLoadingContent()
            let window = UIApplication.shared.keyWindow?.subviews.last
            window?.removeFromSuperview()
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.emailSent()
            }
            
        })
    }
    
    func checkVerification(email:String, password: String) {
        
        self.view?.beginLoadingContent()
        DataManager.instance.signIn(email, password) { (error) in
            
            self.view?.endLoadingContent()
            let window = UIApplication.shared.keyWindow?.subviews.last
            window?.removeFromSuperview()
            
            if isBetaDemo {

                self.view?.verified()
            }
            else {
                
                if let error = error {
                    
                    self.view?.errorMessage(error.msg)
                }else{
                    self.view?.verified()
                }
            }
            

            
        }
    }
    
}
