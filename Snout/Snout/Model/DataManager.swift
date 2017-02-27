//
//  UserManager.swift
//  Snout
//
//  Created by Marc Perello on 07/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class DataManager {
    
    static let Instance = DataManager()
    
    // MARK: - User
    
    func setUser(_ data: [String:Any]){
        UserManager.upsertUser(data)
    }
   
    func getUser(callback:@escaping userCallback) {
        
        if AuthManager.Instance.isAuthenticated() {
            loadUser(callback: callback)
        }else{
            callback(UserError.NotAuthenticated.rawValue, nil)
        }
    }
    
    private func loadUser(callback:@escaping userCallback) {
        
        APIManager.Instance.performCall(.getuser) { (error, data) in
            if error == nil && data != nil {
                guard let userData = data!["user"] as? [String:Any] else {
                    callback(-1, nil)
                    return
                }
                UserManager.upsertUser(userData)
                UserManager.getUser(callback)
            }else{
                print(error ?? "")
                print(data ?? "")
//                callback(error?.specificCode, nil)
                UserManager.getUser(callback)
            }
        }
    }
    
    func saveUser(user:User, phone:[String:Any]?, address:[String:Any]?, callback: @escaping userCallback) {
       
        APIManager.Instance.performCall(.setuser, UserManager.parseUser(user, phone, address)) { (error, data) in
            if error == nil && data != nil {
                guard let userData = data!["user"] as? [String:Any] else {
                    callback(-1, nil)
                    return
                }
                UserManager.upsertUser(userData)
                UserManager.getUser(callback)
            }else{
                print(error ?? "")
                print(data ?? "")
                callback(error?.specificCode, nil)
            }
        }
    }
    
    func removeUser() -> Bool {
        if AuthManager.Instance.isAuthenticated() {
            return UserManager.removeUser()
        }
        return true
    }
    
    // MARK: - Pet
    
    // MARK: - Country Codes
    
    func getCountryCodes() -> [CountryCode]? {
        return CountryCodeManager.getAll()
    }
    
    func getCurrentCountryCode() -> String? {
        return CountryCodeManager.getCurrent()
    }
    

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
}



