//
//  AddressManager.swift
//  PawTrails
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class LocationManager {
    
    static func set(_ data:Any?, to pet: inout Pet){
        
        if pet.last_location == nil {
            pet.setValue(store(data), forKey: "last_location")
        }else{
            if data != nil {
                update(&pet.last_location!, with: data)
            }else{
                pet.setValue(nil, forKey: "last_location")
            }
        }
    }
    
    fileprivate static func store(_ data: Any?) -> Location? {
        if let locationData = data as? [String:Any] {
            if let location = try? CoreDataManager.Instance.store("Location", with: locationData) as? Location {
                return location
            }
        }
        return nil
    }
    
    fileprivate static func update(_ location: inout Location, with data: Any?) {
        if let locationData = data as? [String:Any] {
            for k in location.keys {
                location.setValue(locationData[k], forKey: k)
            }
        }
    }

}
