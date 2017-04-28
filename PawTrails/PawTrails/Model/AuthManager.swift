//
//  ModelManager.swift
//  PawTrails
//
//  Created by Marc Perello on 02/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias errorCallback = (_ error:ErrorMsg?) -> Void


class AuthManager {
    
    static let Instance = AuthManager()


    func isAuthenticated() -> Bool {
       return SharedPreferences.has(.id) && SharedPreferences.has(.token)
    }
    
    func socialMedia() -> String? {
        return SharedPreferences.get(.socialnetwork) 
    }
    
    func signUp(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error, data))
            }else if let data = data {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    func signIn(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signin, with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else if let data = data {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    func login(socialMedia: SocialMedia, _ token: String, completition: @escaping errorCallback){
        let data = ["loginToken":token]
        APIManager.Instance.perform(call: APICallType(socialMedia), with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else if let data = data {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    fileprivate func succeedLoginOrRegister(_ data:[String:Any], completition: @escaping errorCallback){
        
        guard let token = data["token"] as? String else {
            completition(Message.Instance.authError(type: .EmptyUserTokenResponse))
            return
        }
        guard let userData = data["user"] as? [String:Any] else {
            completition(Message.Instance.authError(type: .EmptyUserResponse))
            return
        }
        guard let userId = userData["id"] as? String else {
            completition(Message.Instance.authError(type: .EmptyUserIdResponse))
            return
        }
        if let socialNetwork = data["social_network"] as? String {
            SharedPreferences.set(.socialnetwork, with: socialNetwork)
        }
        if let socialNetworkId = data["social_network_id"] as? String {
            SharedPreferences.set(.socialnetworkId, with: socialNetworkId)
        }
        SharedPreferences.set(.token, with: token)
        SharedPreferences.set(.id, with: userId)
        DataManager.Instance.setUser(userData)
        completition(nil)
    }
    
    func signOut() -> Bool {
        //wipe out DB
        try? CoreDataManager.Instance.delete(entity: "User")
        try? CoreDataManager.Instance.delete(entity: "Pet")
//        GIDSignIn.sharedInstance().signOut()
        return SharedPreferences.remove(.id) && SharedPreferences.remove(.token)
    }
    
    func sendPasswordReset(_ email:String, completition: @escaping errorCallback) {
        let data = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]

        APIManager.Instance.perform(call: .passwordReset, with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else{
                completition(nil)
            }
        }
    }
    
    func changeUsersPassword(_ email:String, _ password:String, _ newPassword:String, completition: @escaping errorCallback) {
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else{
                completition(nil)
            }
        }
    }
    
    fileprivate func handleAuthErrors(_ error: APIManagerError?, _ data: [String:Any]? = nil) -> ErrorMsg? {
        if error != nil {
            return error?.info()
        }
        return nil
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
