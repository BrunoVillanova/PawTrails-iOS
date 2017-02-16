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
}

class InitialPresenter {
    
    weak fileprivate var initialView: InitialView?
    
    func attachView(_ vc: InitialViewController){
        self.initialView = vc
        addSocialMediaButtons(to: vc.view)
    }
    
    func deteachView() {
        self.initialView = nil
    }
    
    //MARK: - Social Media
    
    func addSocialMediaButtons(to view:UIView){
        addFBButton(view: view)
    }
    
    //Facebook
    
    private func addFBButton(view:UIView){
        let width:CGFloat = 150.0
        let height:CGFloat = 30.0
        let frame = CGRect(x: view.center.x - CGFloat(width/2.0), y: view.center.y, width: width, height: height)
        view.addSubview(LoginButton(frame: frame, readPermissions: [.publicProfile, .email]))
    }
    
    private func checkFB() -> Bool {
        return AccessToken.current == nil
    }
    
    private func getFBUserInfo() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                print(value.dictionaryValue ?? "")
                print(value.dictionaryValue ?? "")
            case .failed(let error):
                print(error)
            }
        }
    }
}
