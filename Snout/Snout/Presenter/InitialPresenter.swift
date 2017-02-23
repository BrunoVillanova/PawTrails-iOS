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
    
//    private func addFBButton(view:UIView){
//        let width:CGFloat = 150.0
//        let height:CGFloat = 30.0
//        let frame = CGRect(x: view.center.x - CGFloat(width/2.0), y: view.center.y, width: width, height: height)
//        view.addSubview(LoginButton(frame: frame, readPermissions: [.publicProfile, .email]))
//    }
//    
//    private func checkFB() -> Bool {
//        return AccessToken.current == nil
//    }
//    
//    private func getFBUserInfo() {
//        let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
//        request.start { (response, result) in
//            switch result {
//            case .success(let value):
//                print(value.dictionaryValue ?? "")
//                print(value.dictionaryValue ?? "")
//            case .failed(let error):
//                print(error)
//            }
//        }
//    }
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
            }
        }
    }
}
