//
//  ModelExtensions.swift
//  PawTrails
//
//  Created by Marc Perello on 29/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

//import Foundation
import CoreData

// MARK:- Own Data Management

extension Pet {
        
    var breedsString: String? {
        
        var outBreeds: String?
        
        if let breeds = breeds {
            
            if let first = breeds.first {
                outBreeds = first.name
                
                if let second = breeds.second {
                    outBreeds = outBreeds?.appending(" - \(second.name )")
                }
            }else if let other = breeds.description {
                outBreeds = other
            }
        }
        return outBreeds
    }
    
    var typeString: String? {
        
        if let pettype = type {
            if let type = pettype.type{
                if let typeDescription = pettype.description {
                    return type.name + " - " + typeDescription
                }
                return type.name
            }
        }
        return nil
    }
    
    var weightString: String? {
        if let weight = weight, weight != 0.0 { return "\(weight)" }
        return nil
    }
    
    var weightWithUnitString: String? {
        if let weight = weight, weight != 0.0 { return "\(weight)Kg" }
        return nil
    }
    
    var owner: PetUser? {
        
        if let users = users {
            let owners = users.filter({ $0.isOwner })
            if owners.count == 1 {return owners[0]}
        }
        return nil
    }
    
    var sortedUsers: [PetUser]? {
        if let petUsers = users {
            return petUsers.sorted(by: { (pu1, pu2) -> Bool in
                return pu2.isOwner
            })
        }
        return nil
    }
    
    var sortedSafeZones: [SafeZone]? {
        if let safezones = safezones {
            return safezones.sorted(by: { (sz1, sz2) -> Bool in
                return sz1.id > sz2.id
            })
        }
        return nil
    }
}

extension Phone {
    
    var toString:String? {
        
        guard let number = self.number else {
            return nil
        }
        
        guard let country_code = self.countryCode else {
            return nil
        }
        return "\(country_code) \(number)"
    }
}

extension Address {
    
    var toString: String? {
        
        var desc = [String]()
        if line0 != nil && line0 != "" { desc.append(line0!)}
        if line1 != nil && line1 != "" { desc.append(line1!)}
        if line2 != nil && line2 != "" { desc.append(line2!)}
        if city != nil && city != "" { desc.append(city!)}
        if postalCode != nil && postalCode != "" { desc.append(postalCode!)}
        if state != nil && state != "" { desc.append(state!)}
        if country != nil && country != "" { desc.append(country!)}
        return desc.joined(separator: ", ")
        
    }
    
//    func update(with data:[String:String]) {
//        for (k,v) in data {
//            if self.keys.contains(k) {
//                self.setValue(v, forKey: k)
//            }
//        }
//    }
    
}

//MARK:- Data Management

extension NSManagedObject {
    
    public var toStringDict: [String:String] {
        var out = [String:String]()
        for k in self.entity.attributesByName.keys {
            if let value = self.value(forKey: k) as? String {
                out[k] = value
            }
        }
        return out
    }
    
    public var toDict: [String:Any] {
        var out = [String:Any]()
        for k in self.entity.attributesByName.keys {
            if let value = self.value(forKey: k) {
                out[k] = value
            }
        }
        return out
    }
    
    
    public var keys: [String] {
        return Array(self.entity.attributesByName.keys)
    }
}

public enum NSPredicateOperation: String {
    case equal = "=="
    case contains = "CONTAINS[cd]"
    case beginsWith = "BEGINSWITH[cd]"
}

extension NSPredicate {
    
    fileprivate enum concatOperation: String {
        case and = "&&"
        case or = "||"
    }
    
    convenience init(_ left:String, _ operation:NSPredicateOperation, _ right:Any) {
//        self.init(format: "\(left) \(operation.rawValue) \"\(right)\"")
        self.init(format: "\(left) \(operation.rawValue) %@", argumentArray: [right])
    }
    
    func and(_ left:String, _ op:NSPredicateOperation, _ right:Any) -> NSPredicate {
        return concatFormat(.and, left, op, right)
    }
    
    func or(_ left:String, _ op:NSPredicateOperation, _ right:Any) -> NSPredicate {
        return concatFormat(.or, left, op, right)
    }
    
    fileprivate func concatFormat(_ concatOp: concatOperation, _ left:String, _ op:NSPredicateOperation, _ right:Any) -> NSPredicate {
        return NSPredicate(format: "\(self.predicateFormat) \(concatOp.rawValue) \(left) \(op.rawValue) %@", argumentArray: [right])
    }
}
























