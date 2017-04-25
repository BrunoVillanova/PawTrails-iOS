//
//  Weight.swift
//  PawTrails
//
//  Created by Marc Perello on 20/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

public class Weight: NSObject, NSCoding {
    enum massUnit: Int {
        
        case kg = 0, lbs
        
        var name: String {
            switch self {
            case .kg: return "Kg"
            case .lbs: return "lbs"
            }
        }
    }
    
    var unit: massUnit
    var amount: Double
    
    override init() {
        unit = .kg
        amount = 0.0
        super.init()
    }
    
    init(_ amount: Double, unit: massUnit = massUnit.kg) {
        self.amount = amount
        self.unit = unit
    }
    
    required public init?(coder aDecoder: NSCoder) {
        unit = massUnit(rawValue: aDecoder.decodeInteger(forKey: "unit")) ?? .kg
        amount = aDecoder.decodeDouble(forKey: "amount")
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(unit.rawValue, forKey: "unit")
        aCoder.encode(amount, forKey: "amount")
    }
    
    func toString() -> String {
        return "\(amount) \(unit.name)"
    }
}
