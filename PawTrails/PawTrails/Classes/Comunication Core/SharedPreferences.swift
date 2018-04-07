//
//  SharedPreferences.swift
//  PawTrails
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

/// Performs management of user shared preferences
public class SharedPreferences {
    
    enum key: String {
        case token = "token"
        case id = "id"
        case socialnetwork = "socialnetwork"
    }
    
    /// Get *Value* for *key*
    ///
    /// - Parameter key: key
    /// - Returns: the value of the key, if the key is not found:
    ///     * if the key is the **token**, loads authentication
    ///     * if not, it returns string empty
    static func get(_ key:key) -> String {
        if let value = UserDefaults.standard.string(forKey: key.rawValue) {
            return value
        }else if key == .id || key == .token {
//            (UIApplication.shared.delegate as? AppDelegate)?.loadAuthenticationScreen()
            return ""
        }else{
            return ""
        }
    }
    
    /// Set *Value* for *key*
    ///
    /// - Parameters:
    ///   - key: key
    ///   - with: value
    static func set(_ key:key, with:String) {
        UserDefaults.standard.set(with, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    /// Remove *key*
    ///
    /// - Parameter key: key
    /// - Returns: returns if the value has been removed successfully
    static func remove(_ key:key) -> Bool {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
        return has(key) == false
    }
    
    /// Check key value
    ///
    /// - Parameter key: key
    /// - Returns: returns if value for key exists
    static func has(_ key:key) -> Bool {
        return UserDefaults.standard.string(forKey: key.rawValue) != nil
    }
}
