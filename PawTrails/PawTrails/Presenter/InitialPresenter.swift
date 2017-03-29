//
//  InitialPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin
import TwitterKit

protocol InitialView: NSObjectProtocol, View, ConnectionView {
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
            AuthManager.Instance.signIn(email!, password!) { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        if error?.code == ErrorCode.AccountNotVerified {
                            self.view?.verifyAccount(email!)
                        }else{
                            self.view?.errorMessage(error!)
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
            AuthManager.Instance.signUp(email!, password!) { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self.view?.errorMessage(error!)
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
        
        if !password!.isValidPassword {
            self.view?.passwordFieldError(msg: Message.Instance.authError(type: .WeakPassword).msg)
            return false
        }
        return true
    }
    
    //MARK: - Social Media
    
    //Facebook
    
    func loginFB(vc: InitialViewController) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: vc) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.view?.errorMessage(ErrorMsg(title:"Error login Facebook", msg:"\(error)"))
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                self.view?.loggedSocialMedia()
            }
        }
    }
    
    func loginG(vc: InitialViewController) {
//        let loginManager = LoginManager()
//        loginManager.logIn([ .publicProfile, .email ], viewController: vc) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                self.view?.errorMessage(errorMsg(title:"Error login Facebook", msg:"\(error)"))
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                print("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken)")
//                self.view?.loggedSocialMedia()
//            }
//        }
    }
    
    func loginTW(vc: InitialViewController) {

        Twitter.sharedInstance().logIn(with: vc, methods: .webBased) { (session, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.view?.errorMessage(ErrorMsg(title:"Error Twitter Login", msg:"\(error.localizedDescription)"))
                }
            }else if let session = session {
                // log in
                debugPrint(session)
                // return
                let client = TWTRAPIClient.withCurrentUser()
                let request = client.urlRequest(withMethod: "GET",
                                                url: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                                          parameters: ["include_email": "true", "skip_status": "true"],
                                                          error: nil)
                
                client.sendTwitterRequest(request) { response, data, connectionError in
                
                    if let data = data {
                        
                        if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] {
                            debugPrint(json ?? "no json provided")
                            
                            if let email = json?["email"] {
                                print(email)
                            }
                            
                        }else{
                            debugPrint("json parse failed")
                        }
                    }else{
                        debugPrint("nil data :(")
                    }
                    
                }
                self.view?.loggedSocialMedia()
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
