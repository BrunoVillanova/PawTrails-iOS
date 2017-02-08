//
//  Mapper.swift
//  Snout
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

/**
Allows to map *Any* type from a dictionary to a swift basic type.
 
 - Requires: Use of basic swift objects.
 
 - Version: 1.0
 
 - Author: Marc Perello
 
 */
class Mapper {
    
    fileprivate var json: [String:Any]
    
    required init (_ input: [String:Any]){
        json = input
    }
    
    /**
     Map object from key in dictionary.
     
     - Parameter key: The name of the key to map.
     - Returns: The mapped object from dictionary.
     
     - Precondition: **Mapper** should be initialized with a valid dictionary.
     
     */
    func from<T>(_ key:String) throws -> T {
        
        if json[key] == nil {
            throw NSError(domain: "\(key) was not found in the dictionary", code: 0, userInfo: json)
        }
        
        if let out = json[key] as? T {
            return out
        }
        throw NSError(domain: "Mapping error: \(T.self) requested and found \(json[key])", code: 1, userInfo: json)
    }

    /**
     Map optional object from key in dictionary.
     
     - Parameter key: The name of the key to map.
     - Returns: The mapped object from dictionary or *nil* if the was not found.
     
     - Precondition: **Mapper** should be initialized with a valid dictionary.
     
     */
    func fromOptional<T>(_ key:String) -> T? {
        return try? from(key)
    }
    
}
