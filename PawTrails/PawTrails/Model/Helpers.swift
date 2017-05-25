//
//  Type.swift
//  PawTrails
//
//  Created by Marc Perello on 19/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import MapKit

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

public enum Shape: Int16 {
    case circle = 2
    case square = 4
    
    static func count() -> Int {
        return 2
    }
    
    var code:String? {
        switch self {
        case .circle: return "2"
        case .square: return "4"
        }
    }
    
    static func build(code:String?)  -> Shape? {
        if let code = code {
            switch code {
            case "2": return Shape.circle
            case "4": return Shape.square
            default: return nil
            }
        }else{
            return nil
        }
    }
}

public class Point: NSObject, NSCoding {
    
    var latitude: Double
    var longitude: Double
    
    var toDict: [String:Any] {
        return ["lat":latitude, "lon":longitude] as [String:Any]
    }
        
    override init() {
        latitude = 0.0
        longitude = 0.0
    }
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ data:[String:Any]) {
        latitude = data.tryCastDouble(for: "lat") ?? 0.0
        longitude = data.tryCastDouble(for: "lon") ?? 0.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        latitude = aDecoder.decodeDouble(forKey: "latitude")
        longitude = aDecoder.decodeDouble(forKey: "longitude")
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }
    
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


class Fence: NSObject {
    
    let layer: CALayer
    let line: CALayer
    var shape:Shape {
        didSet {
            updateCornerRadius()
        }
    }
    var isIdle:Bool {
        didSet {
            updateFillColor()
        }
    }
    
    static var idleColor = UIColor.orange().withAlphaComponent(0.5)
    static var noIdleColor = UIColor.red.withAlphaComponent(0.5)
    
    convenience init(_ center: CGPoint, _ topCenter: CGPoint, shape: Shape) {
        self.init(frame: CGRect(center: center, topCenter: topCenter), shape: shape)
    }
    
    init(frame: CGRect, shape:Shape) {
        self.shape = shape
        isIdle = true
        
        layer = CALayer()
        layer.frame = frame
        layer.backgroundColor =  Fence.idleColor.cgColor
        layer.cornerRadius = shape == .circle ? layer.frame.width / 2.0 : 0.0
        
        line = CALayer()
        line.frame = CGRect(x: layer.frame.origin.x + layer.frame.width / 2.0, y: layer.frame.origin.y, width: 1.0, height: layer.frame.height/2.0)
        line.backgroundColor = UIColor.orange().cgColor
    }
    
    
    func setFrame(_ frame:CGRect) {
        layer.frame = frame
        updateCornerRadius()
    }
    
    private func updateCornerRadius(){
        layer.cornerRadius = shape == .circle ? layer.frame.width / 2.0 : 0.0
    }
    
    private func updateFillColor(){
        layer.backgroundColor = isIdle ? Fence.idleColor.cgColor : Fence.noIdleColor.cgColor
    }
    
    var x0: CGFloat { return layer.frame.origin.x }
    var y0: CGFloat { return layer.frame.origin.y }
    var xf: CGFloat { return x0 + layer.frame.width }
    var yf: CGFloat { return y0 + layer.frame.height }
    
    var center: CGPoint {
        return CGPoint(x: layer.frame.origin.x + layer.frame.width / 2.0, y: layer.frame.origin.y + layer.frame.height / 2.0)
    }
    var topCenter: CGPoint {
        return CGPoint(x: layer.frame.origin.x + layer.frame.width / 2.0, y: layer.frame.origin.y)
    }

}
