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
    
    public func toString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.string(from: self)
     }
    
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
    
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date)) years ago"   }
        if months(from: date)  > 0 { return "\(months(from: date)) months ago"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date)) weeks ago"   }
        if days(from: date)    > 0 { return "\(days(from: date)) days ago"    }
        if hours(from: date)   > 0 { return "\(hours(from: date)) hours ago"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) minutes ago" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) seconds ago" }
        return "recently"
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
            if value is NSNumber { return (value as? NSNumber)?.doubleValue }
            if value is Double { return value as? Double }
            if value is String { return NumberFormatter().number(from: value as! String)?.doubleValue }
        }
        return nil
    }
    
    var detailedDescription: String {
        
        var out = "\n"
        
        for (key,value) in self {
            out.append("\(key):\(value) as \(type(of: value))\n")
        }
        
        return out
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












































