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

protocol InitialView: NSObjectProtocol, View {
    func loggedSocialMedia()
}

class InitialPresenter {
    
    weak fileprivate var view: InitialView?
    
    func attachView(_ view: InitialView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    //MARK: - Social Media
    
    //Facebook
    

    
    func loginFB(vc: InitialViewController) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: vc) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.view?.errorMessage(errorMsg(title:"Error login Facebook", msg:"\(error)"))
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                self.view?.loggedSocialMedia()
            }
        }

    }
}
