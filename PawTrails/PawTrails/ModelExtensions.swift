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
    
    var breeds: String? {
        
        var breeds: String?
        
        if let first = firstBreed {
            breeds = first.name
            
            if let second = secondBreed {
                breeds = breeds?.appending(" - \(second.name ?? "")")
            }
        }else if let other = breed_descr {
            breeds = other
        }
        return breeds
        
    }
    
    var typeString: String? {
        
        if let type = Type(rawValue: Int(type)) {
            if let typeDescription = type_descr {
                return type.name + " - " + typeDescription
            }
            return type.name
        }
        return nil
    }
    
    var owner: PetUser? {
        
        if let users = users?.allObjects as? [PetUser] {
            let owners = users.filter({ $0.isOwner })
            if owners.count == 1 {return owners[0]}
        }
        return nil
    }
    
    var isOwner: Bool {
        
        guard let currentId = SharedPreferences.get(.id) else { return false }
        guard let petId = owner?.id else { return false }
        return currentId == petId
    }
    
    func isOwner(_ user: PetUser) -> Bool {
        guard let userId = user.id else { return false }
        guard let petId = owner?.id else { return false }
        return userId == petId
    }
    
}

extension Phone {
    
    var toString:String? {
        
        guard let number = self.number else {
            return nil
        }
        
        guard let country_code = self.country_code else {
            return nil
        }
        return "\(country_code) \(number)"
    }
    
    var toServerDict: [String:Any]? {
        
        guard let number = self.number else {
            return nil
        }
        
        guard let code = self.country_code else {
            return nil
        }
        
        var phoneData = [String:Any]()
        phoneData["number"] = number
        phoneData["country_code"] = code
        return phoneData
    }
    
}

extension Address {
    
    var toString: String? {
        
        let address = self.toStringDict
        
        if address.count == 0 { return nil }
        
        var desc = [String]()
        if address["line0"] != nil && address["line0"] != "" { desc.append(address["line0"]!)}
        if address["line1"] != nil && address["line1"] != "" { desc.append(address["line1"]!)}
        if address["line2"] != nil && address["line2"] != "" { desc.append(address["line2"]!)}
        if address["city"] != nil && address["city"] != "" { desc.append(address["city"]!)}
        if address["postal_code"] != nil && address["postal_code"] != "" { desc.append(address["postal_code"]!)}
        if address["state"] != nil && address["state"] != "" { desc.append(address["state"]!)}
        if address["country"] != nil && address["country"] != "" { desc.append(address["country"]!)}
        return desc.joined(separator: ", ")
        
    }
    
    func update(with data:[String:String]) {
        for (k,v) in data {
            if self.keys.contains(k) {
                self.setValue(v, forKey: k)
            }
        }
    }
    
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
        self.init(format: "\(left) \(operation.rawValue) '\(right)'")
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
