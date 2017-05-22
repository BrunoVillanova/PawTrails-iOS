//
//  UserManager.swift
//  PawTrails
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

typealias userCallback = (_ error:UserError?, _ user:User?) -> Void

import Foundation

class UserManager {
    
    static func upsert(_ data: [String:Any], callback:userCallback? = nil) {
        
        do {
            
            if let id = data.tryCastInteger(for: "id") {
                
                if let user = try CoreDataManager.Instance.upsert("User", with: ["id":id]) as? User {
                    
                    user.name = data["name"] as? String
                    user.surname = data["surname"] as? String
                    user.email = data["email"] as? String
                    user.notification = data["notification"] as? Bool ?? false
                    
                    user.birthday = (data["date_of_birth"] as? String)?.toDate
                    
                    if let genderCode = data["gender"] as? String {
                        user.gender = Gender.build(code: genderCode)?.rawValue ?? -1
                    }
                    
                    // Address
                    
                    if let addressData = data["address"] as? [String:Any] {
                        
                        if user.address == nil { // Create
                            user.address = try CoreDataManager.Instance.store("Address", with: addressData) as? Address
                        }else{ // Update
                            for key in user.address!.keys {
                                user.address!.setValue(addressData[key], forKey: key)
                            }
                        }
                    }else{ //Remove
                        user.setValue(nil, forKey: "address")
                    }
                    
                    // Phone
                    
                    if let phoneData = data["mobile"] as? [String:Any] {
                        
                        if user.phone == nil { // Create
                            user.phone = try CoreDataManager.Instance.store("Phone", with: phoneData) as? Phone
                        }else{ // Update
                            for key in user.phone!.keys {
                                user.phone!.setValue(phoneData[key], forKey: key)
                            }
                        }
                        
                    }else{ //Remove
                        user.setValue(nil, forKey: "phone")
                    }
                    
                    // Image
                    
                    if let imageURL = data["img_url"] as? String {
                        
                        if user.imageURL == nil || (user.imageURL != nil && user.imageURL != imageURL) {
                            user.imageURL = imageURL
                            user.image = Data.build(with: imageURL)
                        }
                    }
                    
                    try CoreDataManager.Instance.save()
                    
                    if let callback = callback { callback(nil, user) }
                    return
                }
                
            }
        } catch {
            //
            debugPrint(error)
        }
        if let callback = callback { callback(nil, nil) }
    }
    
    static func get(_ callback:userCallback) {
        
        guard let id = SharedPreferences.get(.id) else {
            callback(UserError.IdNotFound, nil)
            return
        }
        
        if let results = CoreDataManager.Instance.retrieve("User", with: NSPredicate("id", .equal, id)) as? [User] {
            if results.count > 1 {
                callback(UserError.MoreThenOneUser, nil)
            }else{
                callback(nil, results.first!)
            }
        }else{
            callback(UserError.UserNotFoundInDataBase, nil)
        }
    }

    static func remove() -> Bool {
        guard let id = SharedPreferences.get(.id) else {
            return false
        }
        try? CoreDataManager.Instance.delete(entity: "user", withPredicate: NSPredicate("id", .equal, id))
        return true
    }
    
}

class CountryCodeManager {
    
    fileprivate static func get(_ data:Any?) -> CountryCode? {
        if let cc = data as? String {
            if cc == "" { return nil }
            var countryCode = get(cc)
            if countryCode == nil {
                CSVParser.Instance.loadCountryCodes()
                countryCode = get(cc)
            }
            return countryCode
            
        }
        return nil
    }
    
    static func get(_ code:String) -> CountryCode? {
        if let ccResults = CoreDataManager.Instance.retrieve("CountryCode", with: NSPredicate("code", .equal, code)) as? [CountryCode] {
            if ccResults.count == 1 {
                return ccResults.first!
            }
        }
        return nil
    }
    
    static func getCurrent() -> String? {
        return Locale.current.regionCode
    }
    
    static func getAll() -> [CountryCode]? {
        let results = CoreDataManager.Instance.retrieve("CountryCode") as? [CountryCode]
        if results == nil || results?.count == 0 {
            CSVParser.Instance.loadCountryCodes()
            return CoreDataManager.Instance.retrieve("CountryCode") as? [CountryCode]
        }
        return results
    }
    
}


