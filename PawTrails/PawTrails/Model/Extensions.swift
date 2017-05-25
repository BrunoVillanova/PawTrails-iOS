//
//  Extensions.swift
//  PawTrails
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


// MARK:- Data Management

extension String {
    
    public var isValidEmail:Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailTest.evaluate(with: self)
    }
    
    
    public var isValidPassword:Bool {
        let lower = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
        let upper = CharacterSet(charactersIn: "ABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        let numbers = CharacterSet(charactersIn: "0123456789")
        //        let special = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789").inverted
        return self.rangeOfCharacter(from: lower) != nil && self.rangeOfCharacter(from: upper) != nil && self.rangeOfCharacter(from: numbers) != nil && self.characters.count > 7
    }
    
    public var isValidCode:Bool {
        return URL(string:self) != nil
    }
    
    public var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
    
    public var toInt16: Int16? {
        if let value = Int.init(self) {
            return Int16(value)
        }
        return nil
    }

}

extension Double {
    
    public var toWeightString: String {
        return "\(self)Kg"
    }
    
    public var toDegrees: Double {
        return self * 180.0 / Double.pi
    }
    
    public var square: Double {
        return pow(self, 2.0)
    }
}

extension Date {
    
    public var toStringShow: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    public var toStringServer: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

extension NSDate {
    
    public var toStringShow: String? {
        return (self as Date).toStringShow
    }
    public var toStringServer: String? {
        return (self as Date).toStringServer
    }
}

extension Int {
    
    public var toInt16: Int16 {
        return Int16(self)
    }
    
    public var toString: String {
        return "\(self)"
    }
}

extension Dictionary {
    
    /// Returns a new dictionary filtering the specified keys
    func filtered(by keys:[String]) -> Dictionary {
        
        let out = NSMutableDictionary(dictionary: self)
        
        for key in keys {
            out.removeObject(forKey: key)
        }
        return NSDictionary(dictionary: out) as! Dictionary<Key, Value>
    }
    
    /// filters the values by the specified keys
    mutating func filter(by keys:[String]) {
        self = filtered(by: keys)
    }
}



extension Dictionary where Key == String, Value == Any {
    
    /// Changes nil values to String.Empty
    mutating func jsonSetup() {
        for (key,_) in self {
            if self[key] == nil {
                self.updateValue("", forKey: key)
            }
        }
    }
    
    func tryCastInteger(for key:String) -> Int? {
        if let value = self[key] {
            if value is Int { return value as? Int }
            if value is String, let intValue = Int(value as! String) { return intValue }
        }
        return nil
    }
    
    func tryCastDouble(for key:String) -> Double? {
        if let value = self[key] {
            if value is Double { return value as? Double }
            if value is String, let doubleValue = Double(value as! String) { return doubleValue }
        }
        return nil
    }    
}

extension Data {
    
    
    static func build(with url:String) -> Data? {
        if let url = URL(string: url) {
            do {
                return try Data(contentsOf: url)
            } catch {
                return nil
            }
        }
        return nil
    }
    
    
    
}

extension CGPoint {

    func distance(to point:CGPoint) -> Double {
        return sqrt(Double(pow(abs(self.x-point.x), 2)+pow(abs(self.y-point.y), 2)))
    }
    
}


//public extension XCTest {
//    
//    public func XCTFound(key:String, in data:[String:Any]){
//        guard data[key] != nil else {
//            XCTFail("Error \(key) not found")
//            return
//        }
//    }
//    
//    public func XCTMatch <T: Equatable> (key:String, value:T, in data:[String:Any]){
//        guard data[key] != nil else {
//            XCTFail("Error \(key) not found")
//            return
//        }
//        if data[key] is T  {
//            XCTAssert((data[key] as! T) == value, "\(key) not match \(String(describing: data[key])) != \(value)")
//            return
//        }else{
//            XCTFail("\(key) has wrong object type match \(String(describing: data[key])) != \(value)")
//            return
//        }
//    }
//    
//    public func XCTGet(key:String, in data:[String:Any]) -> Any {
//        guard let out = data[key] else {
//            XCTFail("Error \(key) not found")
//            return ""
//        }
//        return out
//    }
//    
//}












































