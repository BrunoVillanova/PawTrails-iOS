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
    
    private let tokenKey = "key"
    private let idKey = "id"
    
    fileprivate func setToken(_ token:String){
        UserDefaults.standard.setValue(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.value(forKey: tokenKey) as? String ?? nil
    }
    
    fileprivate func removeToken() -> Bool {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        return getToken() == nil
    }
    
    fileprivate func setId(_ id:String){
        UserDefaults.standard.setValue(id, forKey: idKey)
    }
    
    func getId() -> String? {
        return UserDefaults.standard.value(forKey: idKey) as? String ?? nil
    }
    
    fileprivate func removeId() -> Bool {
        UserDefaults.standard.removeObject(forKey: idKey)
        return getId() == nil
    }
    

    func isAuthenticated() -> Bool {
       return getToken() != nil && getId() != nil
    }
    
    func register(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = ["email":email, "password":password]
        APIManager.Instance.performCall(.register, data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error, data))
            }else if data != nil {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    func signIn(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = ["email":email, "password":password]
        APIManager.Instance.performCall(.signin, data) { (error, data) in
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
        self.setToken(token)
        self.setId(userId)
        DataManager.Instance.setUser(userData)
        completition(nil)
    }
    
    func socialSignIn(token:String, email:String, completition: @escaping errorCallback){
        completition(nil)
    }
    
    func signOut() -> Bool {
        //wipe out DB
        try? CoreDataManager.Instance.delete(entity: "User")
        try? CoreDataManager.Instance.delete(entity: "Pet")
        return self.removeToken() && self.removeId()
    }
    
    func sendPasswordReset(_ email:String, completition: @escaping errorCallback) {
        let data = ["email":email]
        APIManager.Instance.performCall(.passwordReset, data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else{
                completition(nil)
            }
        }
    }
    
    func changeUsersPassword(_ email:String, _ password:String, _ newPassword:String, completition: @escaping errorCallback) {
        let data = ["email":email, "password":password, "newPassword":newPassword]
        APIManager.Instance.performCall(.passwordChange, data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else{
                completition(nil)
            }
        }
    }

    
    fileprivate func handleAuthErrors(_ error: APIManagerError?, _ data: [String:Any]? = nil) -> errorMsg? {
//        if error != nil {
//            if let authError = AuthenticationError(rawValue: error!) {
//                return Message.Instance.authError(type: authError)
//            }else{
//                return Message.Instance.softwareDevelopmentError(data)
//            }
//        }
        return nil
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
