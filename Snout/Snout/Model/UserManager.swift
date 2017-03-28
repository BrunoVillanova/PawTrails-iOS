//
//  UserManager.swift
//  Snout
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

typealias userCallback = (_ error:Int?, _ user:User?) -> Void

import Foundation

class UserManager {
    
    
    static func upsert(_ data: [String:Any]) {
        
        do {
            if let user = try CoreDataManager.Instance.upsert("User", with: data.filtered(by: ["address", "mobile", "img_url", "date_of_birth"])) as? User {
                user.birthday = getBirthdate(data["date_of_birth"])
                
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

                try CoreDataManager.Instance.save()
            }
        } catch {
            //
            debugPrint(error)
        }
    }
    
    static func get(_ callback:userCallback) {
        
        guard let id = SharedPreferences.get(.id) else {
            callback(UserError.IdNotFound.rawValue, nil)
            return
        }
        
        if let results = CoreDataManager.Instance.retrieve("User", with: NSPredicate("id", .equal, id)) as? [User] {
            if results.count > 1 {
                callback(UserError.MoreThenOneUser.rawValue, nil)
            }else{
                callback(nil, results.first!)
            }
        }else{
            callback(UserError.NoUserFound.rawValue, nil)
        }
    }

    static func remove() -> Bool {
        guard let id = SharedPreferences.get(.id) else {
            return false
        }
        try? CoreDataManager.Instance.delete(entity: "user", withPredicate: NSPredicate("id", .equal, id))
        return true
    }
    
    static func parse(_ user:User,_ phone:[String:Any]?,_ address:[String:Any]?) -> [String:Any] {
        var data = [String:Any]()
        data["id"] = user.id
        add(user.name, withKey: "name", to: &data)
        add(user.surname, withKey: "surname", to: &data)
        add(user.email, withKey: "email", to: &data)
        add(user.gender, withKey: "gender", to: &data)
        add(user.birthday?.toStringServer, withKey: "date_of_birth", to: &data)
//        data["date_of_birth"] = user.birthday == nil ? "" : user.birthday!.toStringServer
        add(address, withKey: "address", to: &data)
        add(phone, withKey: "mobile", to: &data)
        return data
    }

    static private func add(_ element:Any?, withKey: String, to data: inout [String:Any]){
        data[withKey] = element == nil ? "" : element!
    }

    private static func getBirthdate(_ data: Any?) -> NSDate? {
        if let dateData = data as? String {
            return dateData.toDate as NSDate?
        }
        return nil
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


