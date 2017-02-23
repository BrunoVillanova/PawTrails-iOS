//
//  PhoneManager.swift
//  Snout
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class PhoneManager {
    
   
    
    static func set(_ data:Any?, to user: inout User){
        
        if user.phone == nil {
            user.setValue(store(data), forKey: "phone")
        }else{
            update(&user.phone!, with: data)
        }
    }
    
    fileprivate static func store(_ data:Any?) -> Phone? {
        if let phoneData = data as? [String:Any] {
            if let phone = try? CoreDataManager.Instance.store(entity: "Phone", withData: phoneData, skippedKeys: ["country_code"]) as? Phone {
                phone?.setValue(CountryCodeManager.get(phoneData["country_code"]), forKey: "country_code")
                _ = try? CoreDataManager.Instance.save()
                return phone
            }
        }
        return nil
    }
    
    fileprivate static func update(_ phone: inout Phone, with data: Any?) {
        if let phoneData = data as? [String:Any] {
            guard let number = phoneData["number"] as? String else {
                return
            }
            guard let ccCode = phoneData["country_code"] as? String else {
                return
            }
            guard let cc = CountryCodeManager.get(ccCode) else {
                return
            }
            phone.number = number
            phone.country_code = cc
        }
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
        if let ccResults = CoreDataManager.Instance.retrieve(entity: "CountryCode", withPredicate: NSPredicate(format: "code == %@",code)) as? [CountryCode] {
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
        let results = CoreDataManager.Instance.retrieve(entity: "CountryCode") as? [CountryCode]
        if results == nil || results?.count == 0 {
            CSVParser.Instance.loadCountryCodes()
            return CoreDataManager.Instance.retrieve(entity: "CountryCode") as? [CountryCode]
        }
        return results
    }

}
