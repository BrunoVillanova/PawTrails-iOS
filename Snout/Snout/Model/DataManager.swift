//
//  UserManager.swift
//  Snout
//
//  Created by Marc Perello on 07/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias userCallback = (_ error:Int?, _ user:User?) -> Void

extension String {
    
    public var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}

extension Date {
    
    public var toStringShow: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }
    public var toStringServer: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

class DataManager {
    
    static let Instance = DataManager()
    
    // MARK: - User
    
    func setUser(_ data: [String:Any]){

        do {
            if let user = try CoreDataManager.Instance.upsert(entity: "User", withData: data, skippedKeys: ["address", "mobile", "img_url"]) as? User {
                user.address = setAddress(data["address"])
                user.phone = setPhone(data["mobile"])
                try CoreDataManager.Instance.save()
            }
        } catch {
            //
        }
    }
    
    private func setAddress(_ data: Any?) -> Address? {
        if let addressData = data as? [String:Any] {
            if let address = try? CoreDataManager.Instance.store(entity: "Address", withData: addressData) as? Address {
                return address
            }
        }
        return nil
    }
    
    private func setPhone(_ data:Any?) -> Phone? {
        if let phoneData = data as? [String:Any] {
            if let phone = try? CoreDataManager.Instance.store(entity: "Phone", withData: phoneData, skippedKeys: ["country_code"]) as? Phone {
                phone?.country_code = setCountryCode(phoneData["country_code"])
                return phone
            }
        }
        return nil
    }
    
    private func setCountryCode(_ data:Any?) -> CountryCode? {
        if let cc = data as? String {
            if cc == "" { return nil }
            var countryCode = getCountryCode(cc)
            if countryCode == nil {
                CSVParser.Instance.loadCountryCodes()
                countryCode = getCountryCode(cc)
            }
            return countryCode
            
        }
        return nil
    }
    
    private func getCountryCode(_ code:String) -> CountryCode? {
        if let ccResults = CoreDataManager.Instance.retrieve(entity: "CountryCode", withPredicate: NSPredicate(format: "code == \(code)")) as? [CountryCode] {
            if ccResults.count == 1 {
                return ccResults.first!
            }
        }
        return nil
    }
    
    func getUser(callback:userCallback) {
        
        if AuthManager.Instance.isAuthenticated() {
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
    }
    
    func removeUser(){
        
    }
    
    // MARK: - Pet
    
    // MARK: - Country Codes
    
    func getCountryCodes() -> [CountryCode]? {
        let results = CoreDataManager.Instance.retrieve(entity: "CountryCode") as? [CountryCode]
        if results == nil || results?.count == 0 {
            CSVParser.Instance.loadCountryCodes()
            return CoreDataManager.Instance.retrieve(entity: "CountryCode") as? [CountryCode]
        }
        return results
    }

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
}
