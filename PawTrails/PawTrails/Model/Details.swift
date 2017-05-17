//
//  Type.swift
//  PawTrails
//
//  Created by Marc Perello on 19/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


public enum Gender: Int16 {
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

public enum Type: Int16 {
    
    case other = 1
    case dog = 2
    case cat = 3
    
    static func count() -> Int {
        return 3
    }
    
    var name:String {
        switch self {
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .other: return "Other"
        }
    }
    
    var code:String {
        switch self {
        case .cat: return "cat"
        case .dog: return "dog"
        case .other: return "other"
        }
    }
    
    static func build(code:String?)  -> Type? {
        if let code = code {
            switch code {
            case "cat": return Type.cat
            case "dog": return Type.dog
            default: return Type.other
            }
        }else{
            return nil
        }
    }
}
