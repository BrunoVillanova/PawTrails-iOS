//
//  Gender.swift
//  Snout
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum Gender: Int {
    case female = 0,male,undefined
    
    static func count() -> Int {
        return 3
    }
    
    var name:String? {
        switch self {
        case .female: return "female"
        case .male: return "male"
        default: return nil
        }
    }
    
    var printName:String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        default: return "Not Specified"
        }
    }
    
    var code:String? {
        switch self {
        case .female: return "F"
        case .male: return "M"
        default: return nil
        }
    }
    
    init(code:String?) {
        if let code = code {
            switch code {
            case "F": self = .female
            case "M": self = .male
            default: self = .undefined
            }
        }else{
            self = .undefined
        }
    }
}
