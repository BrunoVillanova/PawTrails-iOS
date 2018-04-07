//
//  InitialPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin

protocol InitialView: NSObjectProtocol, View, LoadingView {
    func loggedSocialMedia()
    func emailFieldError()
    func passwordFieldError()
    func userAuthenticated()
    func verifyAccount(_ email:String, _ password:String)
}

class InitialPresenter {
    
    weak fileprivate var view: InitialView?
    
    func attachView(_ view: InitialView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func signIn(email:String?, password:String?) {
        if validInput(email, password) {
            view?.beginLoadingContent()
            DataManager.instance.signIn(email!, password!) { (error) in
                self.view?.endLoadingContent()
                if let error = error {
                    
                    if isBetaDemo {
                        
                        self.view?.userAuthenticated()
                    }
                    else {
                        if error.APIError?.errorCode == ErrorCode.AccountNotVerified {
                            self.view?.verifyAccount(email!, password!)
                        }else{
                            self.view?.errorMessage(error.msg)
                        }
                    }
                    
                }else{
                    self.view?.userAuthenticated()
                }
            }
        }
    }
    
    func signUp(email:String?, password:String?) {
        
        if validInput(email, password) {
            view?.beginLoadingContent()
            DataManager.instance.signUp(email!, password!) { (error) in
                self.view?.endLoadingContent()
//                let window = UIApplication.shared.keyWindow?.subviews.last
//                window?.removeFromSuperview()
                
                if let error = error {
//                    if error.msg.msg.count != 0 {
                        self.view?.errorMessage(error.msg)
//                    }
//                    else {
//                        self.view?.verifyAccount(email!, password!)
//                    }
                    
                }else{
                    self.view?.verifyAccount(email!, password!)
                }
            }
        }
    }
    
    private func validInput(_ email:String?, _ password:String?) -> Bool {
        
        if email == nil || (email != nil && email == "") {
            self.view?.emailFieldError()
            return false
        }
        
        if password == nil || (password != nil && password == "") {
            self.view?.passwordFieldError()
            return false
        }
        
        if !email!.isValidEmail {
            self.view?.emailFieldError()
            return false
        }

        return true
    }
    
    //MARK: - Social Media
    
    //Facebook
    
    func loginFB(vc: InitialViewController) {
        LoginManager().logIn(readPermissions: [ .publicProfile, .email ], viewController: vc) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                self.view?.errorMessage(DataManagerError(error: error).msg)
                break
            case .success(_, _, let accessToken):
                DataManager.instance.login(socialMedia: .facebook, accessToken.authenticationToken, callback: { (error) in
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.loggedSocialMedia()
                    }
                })
            default:
                break
            }
        }
    }
}
