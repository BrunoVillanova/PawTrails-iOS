//
//  AddressManager.swift
//  Snout
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class AddressManager {
    
    
    static func upsertAddress(_ data: Any?) -> Address? {
        if let addressData = data as? [String:Any] {
            if let address = try? CoreDataManager.Instance.store(entity: "Address", withData: addressData) as? Address {
                return address
            }
        }
        return nil
    }
    
}
