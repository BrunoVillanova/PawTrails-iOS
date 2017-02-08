//
//  ModelManager.swift
//  Snout
//
//  Created by Marc Perello on 02/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias errorCallback = (_ error:String?) -> Void


class AuthManager {
    
    static let Instance = AuthManager()
    
    
    fileprivate func setToken(_ token:String){
        UserDefaults.standard.setValue(token, forKey: "token")
    }
    
    fileprivate func getToken() -> String? {
        return UserDefaults.standard.value(forKey: "token") as? String ?? nil
    }
    
    func register(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = ["email":email, "password":password]
        APIManager.Instance.performCall(.register, data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else if data != nil {
                do{
                    _ = try UserManager.Instance.saveUser(data!)
                    completition(nil)
                }catch {
                    
                }
            }
        }
    }
    
    func signIn(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = ["email":email, "password":password]
        APIManager.Instance.performCall(.signin, data) { (error, data) in
            if error != nil {
                completition(self.handleAuthErrors(error))
            }else{
                //save user
                completition(nil)
            }
        }
    }
    
//    func googleSignIn(credential:FIRAuthCredential, completition: @escaping errorCallback){
//        completition(nil)
//    }
    
    func signOut(completition: ((_ error:String?) -> Void)?) {
        APIManager.Instance.performCall(.signout) { (error, _) in
            completition!(self.handleAuthErrors(error))
        }
    }
    
    func sendVerificationEmail(completition: @escaping errorCallback) {
        completition(nil)
    }
    
    func sendPasswordReset(_ email:String, completition: @escaping errorCallback) {
        completition(nil)
    }
    
    /**
     Set users password.
     
     - Parameters:
     - email: user email.
     - password: current password.
     - newPassword: new password.
     - completition: callback.
     - error: contains message error or *nil*.
     
     - Remark:
     The email and password must match the current signed in user credentials.
     
     */
    func setUsersPassword(_ email:String, _ password:String, _ newPassword:String, completition: @escaping (_ error:String?) -> Void) {
        completition(nil)
    }
    
    fileprivate func handleAuthErrors(_ error: Error?) -> String? {
        if error != nil {
            return error!.localizedDescription
        }
        return nil
    }

    
}
