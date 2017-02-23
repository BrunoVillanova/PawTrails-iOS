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
            update(&user.address!, with: data)
        }
    }
    
    fileprivate static func store(_ data: Any?) -> Address? {
        if let addressData = data as? [String:Any] {
            if let address = try? CoreDataManager.Instance.store(entity: "Address", withData: addressData) as? Address {
                return address
            }
        }
        return nil
    }
    
    fileprivate static func update(_ address: inout Address, with data: Any?) {
        if let addressData = data as? [String:Any] {
            for (k,v) in addressData {
                address.setValue(v, forKey: k)
            }
        }
    }
    

}
