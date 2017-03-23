//
//  ModelManager.swift
//  Snout
//
//  Created by Marc Perello on 02/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias errorCallback = (_ error:errorMsg?) -> Void


class AuthManager {
    
    static let Instance = AuthManager()


    func isAuthenticated() -> Bool {
       return SharedPreferences.has(.id) && SharedPreferences.has(.token)
    }
    
    func signUp(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error, data))
            }else if data != nil {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    func signIn(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = ["email":email, "password":password]
        APIManager.Instance.perform(call: .signin, with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else if data != nil {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    func signInSocial(_ email:String, _ token: String, completition: @escaping errorCallback){
        let data = ["email":email, "token":token]
        APIManager.Instance.perform(call: .signinsocial, with: data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else if data != nil {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    fileprivate func succeedLoginOrRegister(_ data:[String:Any]?, completition: @escaping errorCallback){
        guard let token = data!["token"] as? String else {
            completition(Message.Instance.authError(type: .EmptyUserTokenResponse))
            return
        }
        guard let userData = data!["user"] as? [String:Any] else {
            completition(Message.Instance.authError(type: .EmptyUserResponse))
            return
        }
        guard let userId = userData["id"] as? String else {
            completition(Message.Instance.authError(type: .EmptyUserIdResponse))
            return
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
        return SharedPreferences.remove(.id) && SharedPreferences.remove(.token)
    }
    
    func sendPasswordReset(_ email:String, completition: @escaping errorCallback) {
        let data = ["email":email]
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

    
    fileprivate func handleAuthErrors(_ error: APIManagerError?, _ data: [String:Any]? = nil) -> errorMsg? {
        if error != nil {
            if let authError = AuthenticationError(rawValue: error!.specificCode) {
                return Message.Instance.authError(type: authError)
            }else{
                return Message.Instance.softwareDevelopmentError(data)
            }
        }
        return nil
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
