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
    
    
    static func upsertUser(_ data: [String:Any]) {
        
        do {
            if var user = try CoreDataManager.Instance.upsert(entity: "User", withData: data, skippedKeys: ["address", "mobile", "img_url", "date_of_birth"]) as? User {
                user.birthday = getBirthdate(data["date_of_birth"])
                AddressManager.set(data["address"], to: &user)
                PhoneManager.set(data["mobile"], to: &user)
                try CoreDataManager.Instance.save()
            }
        } catch {
            //
        }
    }
    
    static func getUser(_ callback:userCallback) {
        
        guard let id = SharedPreferences.get(.id) else {
            callback(UserError.IdNotFound.rawValue, nil)
            return
        }
        
        if let results = CoreDataManager.Instance.retrieve(entity: "User", withPredicate: NSPredicate(format: "id == \(id)")) as? [User] {
            if results.count > 1 {
                callback(UserError.MoreThenOneUser.rawValue, nil)
            }
            callback(nil, results.first!)
        }else{
            callback(UserError.NoUserFound.rawValue, nil)
        }
    }

    static func removeUser() -> Bool {
        guard let id = SharedPreferences.get(.id) else {
            return false
        }
        try? CoreDataManager.Instance.delete(entity: "user", withPredicate: NSPredicate(format: "id == \(id)"))
        return true
    }
    
    static func parseUser(_ user:User,_ phone:[String:Any]?,_ address:[String:Any]?) -> [String:Any] {
        var data = [String:Any]()
        data["id"] = user.id
        add(user.name, withKey: "name", to: &data)
        add(user.surname, withKey: "surname", to: &data)
        add(user.email, withKey: "email", to: &data)
        add(user.gender, withKey: "gender", to: &data)
        data["date_of_birth"] = user.birthday == nil ? "" : user.birthday!.toStringServer
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
