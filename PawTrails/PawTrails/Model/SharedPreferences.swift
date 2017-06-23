//
//  SharedPreferences.swift
//  PawTrails
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

public class SharedPreferences {
    
    enum key: String {
        case token = "token"
        case id = "id"
        case socialnetwork = "socialnetwork"
        case socialnetworkId = "socialnetworkId"
    }
    
    static func get(_ p:key) -> String? {
        return UserDefaults.standard.string(forKey: p.rawValue)
    }
    
    static func set(_ p:key, with:String) {
        UserDefaults.standard.set(with, forKey: p.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func remove(_ p:key) -> Bool {
        UserDefaults.standard.removeObject(forKey: p.rawValue)
        UserDefaults.standard.synchronize()
        return get(p) == nil
    }
    
    static func has(_ p:key) -> Bool {
        return get(p) != nil
    }
}
