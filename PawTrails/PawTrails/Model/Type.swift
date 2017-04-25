//
//  Type.swift
//  PawTrails
//
//  Created by Marc Perello on 19/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum Type: Int {
    
    case other = 1
    case dog = 2
    case cat = 3
    
    static func count() -> Int {
        return 3
    }
    
    var name:String? {
        switch self {
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .other: return "Other"
        }
    }
    
    var code:String? {
        switch self {
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .other: return "Other"
        }
    }
    
    static func build(code:String?)  -> Type? {
        if let code = code {
            switch code {
            case "Cat": return Type.cat
            case "Dog": return Type.dog
            default: return Type.other
            }
        }else{
            return nil
        }
    }
}
