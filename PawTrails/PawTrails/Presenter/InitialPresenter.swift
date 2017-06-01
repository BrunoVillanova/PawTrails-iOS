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
import TwitterKit

protocol InitialView: NSObjectProtocol, View, ConnectionView, LoadingView {
    func loggedSocialMedia()
    func emailFieldError(msg:String)
    func passwordFieldError(msg:String)
    func userAuthenticated()
    func verifyAccount(_ email:String)
}

class InitialPresenter {
    
    weak fileprivate var view: InitialView?
    private var reachability: Reachbility!
    
    func attachView(_ view: InitialView){
        self.view = view
        self.reachability = Reachbility(view)
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func signIn(email:String?, password:String?) {
        
        if validInput(email, password) && reachability.isConnected() {
            view?.beginLoadingContent()
            AuthManager.Instance.signIn(email!, password!) { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        if error.APIError?.errorCode == ErrorCode.AccountNotVerified {
                            self.view?.verifyAccount(email!)
                        }else{
                            self.view?.errorMessage(error.msg)
                        }
                    }else{
                        self.view?.userAuthenticated()
                    }
                }
            }
        }
    }
    
    func signUp(email:String?, password:String?) {
        
        if validInput(email, password) && reachability.isConnected() {
            view?.beginLoadingContent()
            AuthManager.Instance.signUp(email!, password!) { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.verifyAccount(email!)
                    }
                }
            }
        }
    }
    
    private func validInput(_ email:String?, _ password:String?) -> Bool {
        
        if email == nil || (email != nil && email == "") {
            self.view?.emailFieldError(msg: "")
            return false
        }
        
        if password == nil || (password != nil && password == "") {
            self.view?.passwordFieldError(msg: "")
            return false
        }
        
        if !email!.isValidEmail {
            self.view?.emailFieldError(msg: Message.Instance.authError(type: .EmailFormat).msg)
            return false
        }
        
//        if !password!.isValidPassword {
//            self.view?.passwordFieldError(msg: Message.Instance.authError(type: .WeakPassword).msg)
//            return false
//        }
        return true
    }
    
    //MARK: - Social Media
    
    //Facebook
    
    func loginFB(vc: InitialViewController) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: vc) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.view?.errorMessage(DataManagerError(error: error).msg)
                break
            case .success(_, _, let accessToken):
                AuthManager.Instance.login(socialMedia: .facebook, accessToken.authenticationToken, completition: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.view?.errorMessage(error.msg)
                        }else{
                            self.view?.loggedSocialMedia()
                        }
                    }
                })
            default:
                break
            }
        }
    }
    
    //Google
    
    func loginG() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.configureGoogleLogin()
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func successGLogin(token:String) {
        print(token)
        AuthManager.Instance.login(socialMedia: .google, token, completition: { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.view?.errorMessage(error.msg)
                }else{
                    self.view?.loggedSocialMedia()
                }
            }
        })
    }
    
    //Twitter
    
    func loginTW(vc: InitialViewController) {

        Twitter.sharedInstance().start(withConsumerKey: "FM1jiu1Iceq2IwDS6aT41X046", consumerSecret: "QGLiyOInRuZ3DlRXk0mxjWSi1hVUPEhAWl1b92wHp2B5C1Qys9")
        Twitter.sharedInstance().logIn(with: vc, methods: .webBased) { (session, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.view?.errorMessage(DataManagerError(error: error).msg)
                }
            }else if let session = session {
                print(session.authToken)
                AuthManager.Instance.login(socialMedia: .twitter, session.authToken, completition: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.view?.errorMessage(error.msg)
                        }else{
                            self.view?.loggedSocialMedia()
                        }
                    }
                })
            }
        }
    }
}
