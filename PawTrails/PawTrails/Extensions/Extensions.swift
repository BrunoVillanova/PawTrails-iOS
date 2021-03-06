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
        return self.rangeOfCharacter(from: lower) != nil && self.rangeOfCharacter(from: upper) != nil && self.rangeOfCharacter(from: numbers) != nil && self.count > 7
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

    var shortValue: String {
        return String(format: "%g", self)
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
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

extension Int16 {
    
    public var toInt: Int{
        return Int(self)
    }
}

extension Int64 {
    
    func timeStampToTimeString() -> String {
        
        var hours = 0
        var minutes = 0
        var seconds = 0
        
        if let totalTime = self as Int64? {
            hours = Int(totalTime) / 3600
            minutes = Int(totalTime) / 60 % 60
            seconds = Int(totalTime) % 60
        }
        
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
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
    
    init(object: Any) {
        self.init()
        for child in Mirror(reflecting: object).children {
            if let key = child.label {
                self[key] = child.value
            }
        }
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

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension UIDevice {
    var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}


// Date

struct DateComponentUnitFormatter {
    
    private struct DateComponentUnitFormat {
        let unit: Calendar.Component
        
        let singularUnit: String
        let pluralUnit: String
        
        let futureSingular: String
        let pastSingular: String
    }
    
    private let formats: [DateComponentUnitFormat] = [
        
        DateComponentUnitFormat(unit: .year,
                                singularUnit: "year",
                                pluralUnit: "years",
                                futureSingular: "Next year",
                                pastSingular: "Last year"),
        
        DateComponentUnitFormat(unit: .month,
                                singularUnit: "month",
                                pluralUnit: "months",
                                futureSingular: "Next month",
                                pastSingular: "Last month"),
        
        DateComponentUnitFormat(unit: .weekOfYear,
                                singularUnit: "week",
                                pluralUnit: "weeks",
                                futureSingular: "Next week",
                                pastSingular: "Last week"),
        
        DateComponentUnitFormat(unit: .day,
                                singularUnit: "day",
                                pluralUnit: "days",
                                futureSingular: "Tomorrow",
                                pastSingular: "Yesterday"),
        
        DateComponentUnitFormat(unit: .hour,
                                singularUnit: "hour",
                                pluralUnit: "hours",
                                futureSingular: "In an hour",
                                pastSingular: "An hour ago"),
        
        DateComponentUnitFormat(unit: .minute,
                                singularUnit: "minute",
                                pluralUnit: "minutes",
                                futureSingular: "In a minute",
                                pastSingular: "A minute ago"),
        
        DateComponentUnitFormat(unit: .second,
                                singularUnit: "second",
                                pluralUnit: "seconds",
                                futureSingular: "Just now",
                                pastSingular: "Just now"),
        
        ]
    
    func string(forDateComponents dateComponents: DateComponents, useNumericDates: Bool) -> String {
        for format in self.formats {
            let unitValue: Int
            
            switch format.unit {
            case .year:
                unitValue = dateComponents.year ?? 0
            case .month:
                unitValue = dateComponents.month ?? 0
            case .weekOfYear:
                unitValue = dateComponents.weekOfYear ?? 0
            case .day:
                unitValue = dateComponents.day ?? 0
            case .hour:
                unitValue = dateComponents.hour ?? 0
            case .minute:
                unitValue = dateComponents.minute ?? 0
            case .second:
                unitValue = dateComponents.second ?? 0
            default:
                assertionFailure("Date does not have requried components")
                return ""
            }
            
            switch unitValue {
            case 2 ..< Int.max:
                return "\(unitValue) \(format.pluralUnit) ago"
            case 1:
                return useNumericDates ? "\(unitValue) \(format.singularUnit) ago" : format.pastSingular
            case -1:
                return useNumericDates ? "In \(-unitValue) \(format.singularUnit)" : format.futureSingular
            case Int.min ..< -1:
                return "In \(-unitValue) \(format.pluralUnit)"
            default:
                break
            }
        }
        
        return "Just now"
    }
}

extension Date {
    
    func timeAgoSinceNow(useNumericDates: Bool = false) -> String {
        
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let components = calendar.dateComponents(unitFlags, from: self, to: now)
        
        let formatter = DateComponentUnitFormatter()
        return formatter.string(forDateComponents: components, useNumericDates: useNumericDates)
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
