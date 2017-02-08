//
//  UserManager.swift
//  Snout
//
//  Created by Marc Perello on 07/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias userCallback = (_ error:String?, _ user:User?) -> Void

class UserManager {
    
    static let Instance = UserManager()
    
    fileprivate let key = "user"
    
    func saveUser(_ data:[String:Any]) throws -> User {
        UserDefaults.standard.set(data, forKey: key)
        return try User(data)
    }
    
    func getUser() -> User? {
        if let userData = UserDefaults.standard.value(forKey: key) as? [String:Any] {
            return try? User(userData)
        }
        return nil
    }
    
    func requestUser(completion: @escaping userCallback){
        APIManager.Instance.performCall(.getuser) { (error, data) in
            if error != nil {
                completion(error.debugDescription, nil)
            }else if data != nil {
                guard let user = try? self.saveUser(data!) else {
                    completion("",nil)
                    return
                }
                completion(nil, user)
            }
            completion("", nil)
        }
    }
    
    func removeUser() -> Bool {
        UserDefaults.standard.removeObject(forKey: key)
        return UserDefaults.standard.value(forKey: key) == nil
    }
    
}
