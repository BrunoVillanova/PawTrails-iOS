//
//  Model.swift
//  Snout
//
//  Created by Marc Perello on 07/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class Model {
    
    func print() -> String {
        let m = Mirror(reflecting: self)
        return "\(String(describing: self)) : {\n" + m.children.map { $0.value is Model ? "\n\($0.label!): \(($0.value as! Model).print())\n" : "\t\($0.label!): \($0.value)" }.joined(separator: "\n") + "\n}"
    }
}

class Address:Model {
    
    var line0: String
    var line1: String
    var line2: String?
    var city: String
    var state_county: String?
    var country: String
    
    init(_ json: [String:Any]) throws {
        
        let map = Mapper(json)
        
        try line0 = map.from("line0")
        try line1 = map.from("line1")
        line2 = map.fromOptional("line2")
        try city = map.from("city")
        state_county = map.fromOptional("state_county")
        try country = map.from("country")
    }
    
    convenience init(_ any: Any?) throws {
        guard let json = any as? [String:Any] else {
            throw NSError(domain: "Address Not Formated Properly", code: 0, userInfo: ["Input":any!])
        }
        try self.init(json)
    }
    
}


class User: Model {
    
    var id: Int
    var email: String
    var address: Address?
    
    init(_ json: [String:Any]) throws {
        
        let map = Mapper(json)
        
        try id = map.from("id")
        try email = map.from("email")
        if json["address"] != nil { try? address = Address(json["address"]) }
    }
    
}
















