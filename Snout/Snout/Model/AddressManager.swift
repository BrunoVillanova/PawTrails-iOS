//
//  AddressManager.swift
//  Snout
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class AddressManager {
    
    static func set(_ data:Any?, to user: inout User){
        
        if user.address == nil {
            user.setValue(store(data), forKey: "address")
        }else{
            if data != nil {
                update(&user.address!, with: data)
            }else{
                user.setValue(nil, forKey: "address")
            }
        }
    }
    
    static func search(_ key:String) -> [String] {
        
        
        var predicate = NSPredicate("country", .contains, key)
        predicate = predicate.or("city", .contains, key)
        predicate = predicate.or("state", .contains, key)

        if let results = CoreDataManager.Instance.retrieve("Address", with: predicate) as? [Address] {
            return results.map({ $0.toStringDict.map({$0.value}).joined(separator: ", ") })
        }
        return [String]()
    }
    
    fileprivate static func add(predicate: String, with: Any, to format: inout String, to: inout [Any]){
        format.append(predicate)
        to.append(with)
    }
    
    fileprivate static func store(_ data: Any?) -> Address? {
        if let addressData = data as? [String:Any] {
            if let address = try? CoreDataManager.Instance.store("Address", with: addressData) as? Address {
                return address
            }
        }
        return nil
    }
    
    fileprivate static func update(_ address: inout Address, with data: Any?) {
        if let addressData = data as? [String:Any] {
            for k in address.keys {
                address.setValue(addressData[k], forKey: k)
            }
        }
    }

}
