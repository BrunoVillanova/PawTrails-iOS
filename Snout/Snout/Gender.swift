//
//  Gender.swift
//  Snout
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum Gender: Int {
    case female = 0,male, undefined
    
    static func count() -> Int {
        return 3
    }
    
    var name:String? {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .undefined: return "Not Specified"
        }
    }
    
    var code:String? {
        switch self {
        case .female: return "F"
        case .male: return "M"
        case .undefined: return "U"
        }
    }
    
    static func build(code:String?)  -> Gender? {
        if let code = code {
            switch code {
            case "F": return Gender.female
            case "M": return .male
            case "U": return .undefined
            default: return nil
            }
        }else{
            return nil
        }
    }
}
