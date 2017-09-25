//
//  Models.swift
//  PawTrails
//
//  Created by Marc Perello on 26/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK:- User

struct Authentication {
    var token: String?
    var socialNetwork: SocialMedia?
    var user: User?
}

enum SocialMedia: String {
    case facebook = "FB"
    case google = "GL"
    case twitter = "TW"
    case weibo = "WB"
}

struct User {
    var id: Int
    var email: String?
    var name: String?
    var surname: String?
    var birthday: Date?
    var gender: Gender?
    var image: Data?
    var imageURL: String?
    var notification: Bool
    
    var address: Address?
    var phone: Phone?
    var friends: [PetUser]?
}

struct Address {
    var city: String?
    var country: String?
    var line0: String?
    var line1: String?
    var line2: String?
    var postalCode: String?
    var state: String?
}

struct Phone {
    var number: String?
    var countryCode: String?
}

struct CountryCode {
    var code: String?
    var name: String?
    var shortName: String?
}

//MARK:- Pet

struct Pet {
    var id: Int
    var deviceCode: String?
    var name: String?
    var type: PetType?
    var breeds: PetBreeds?
    var gender: Gender?
    var birthday: Date?
    var image: Data?
    var imageURL: String?
    var isOwner: Bool
    var neutered: Bool
    var weight: Double?

    var safezones: [SafeZone]?
    var users: [PetUser]?
}






struct Trip {
    var id: Int
    var name: String?
    var petId: Int
    var status: Int
    var timeStart: Int
    var timeStamp : Int
}




struct TripList {
    var id: Int
    var name: String?
    var petId: Int
    var status: Int
    var startTime: Int
    var stoppedTime: Int?
}




enum status: Int {
    case Active = 0
    case Paused = 1
    case Stopped = 2
    
}



struct PetType {
    var type: Type?
    var description: String?
}

struct PetBreeds {
    var breeds: [Int?]
    var first: Breed?
    var second: Breed?
    var description: String?
}

struct Breed {
    var id: Int
    var name: String
    var type: Type
}

struct SafeZone {
    var id: Int
    var name: String?
    var point1: Point?
    var point2: Point?
    var shape: Shape
    var active: Bool
    var address: String?
    var preview: Data?
}



struct PetUser {
    var id: Int
    var email: String?
    var name: String?
    var surname: String?
    var isOwner: Bool
    var image: Data?
    var imageURL: String?
}

extension PetUser: Equatable {
    static func == (lhs: PetUser, rhs: PetUser) -> Bool {
        return lhs.id == rhs.id
    }
}

//MARK:- Helpers

enum Gender: Int16 {
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

enum Type: Int16 {
    
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

enum Shape: Int16 {
    case circle = 2
    case square = 4
    
    static func count() -> Int {
        return 2
    }
    
    var code:Int {
        switch self {
        case .circle: return 2
        case .square: return 4
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
    
    var toString: String {
        return "\(latitude) - \(longitude)"
    }
    
    override init() {
        latitude = 0.0
        longitude = 0.0
    }
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ data:[String:Any]?) {
        latitude = data?.tryCastDouble(for: "lat") ?? 0.0
        longitude = data?.tryCastDouble(for: "lon") ?? 0.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        latitude = aDecoder.decodeDouble(forKey: "latitude")
        longitude = aDecoder.decodeDouble(forKey: "longitude")
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let point = object as? Point {
            return self.latitude == point.latitude && self.longitude == point.longitude
        }
        return false
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
    
    static var idleColor = UIColor.primary.withAlphaComponent(0.5)
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
        line.backgroundColor = UIColor.primary.cgColor
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

public enum GPSStatus{
    case noDeviceFound, idle, disconected, unknown
}

class GPSData: NSObject {
    
    var status: GPSStatus
    var point: Point
    var signal: Int
    var satellites: Int
    var battery: Int
    var serverDate: Date
    var locationAndTime: String = ""
    var source: String = ""
    
    override init() {
        status = .unknown
        point = Point()
        signal = 0
        satellites = 0
        battery = 0
        serverDate = Date()
    }
    
    convenience init(_ data:[String:Any]) {
        self.init()
        update(data)
    }
    
    func update(_ data:[String:Any]) {
        
        if let statusValue = data["error"] as? Int {
            switch statusValue {
            case 31: status = .noDeviceFound
            default: break
            }
        }else{
            status = .idle
        }
        
        if let pointData = data["deviceData"] as? [String:Any] {
            let newPoint = Point(pointData)
            if point.coordinates.location.coordinateString != newPoint.coordinates.location.coordinateString {
                locationAndTime = ""
                point = newPoint
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Requested for Update \(data["petId"] ?? "")")
                print("Point printed \(newPoint)")
            }
        }else{
            point = Point()
        }
        signal = data.tryCastInteger(for: "netSignal") ?? -1
        satellites = -1
        print(" Printed SIgnal   \(signal)")
        
        if let satellites = data["satSignal"] as? String {
            let components = satellites.components(separatedBy: "-")
            if components.count == 2 {
                let min = Double(components[0]) ?? 0
                let max = Double(components[1]) ?? 0
                let sum = min + max
                if sum > 0 { self.satellites = Int(sum/2.0) }
            }
        }
        battery = data.tryCastInteger(for: "battery") ?? -1
        if let serverTime = data.tryCastDouble(for: "serverTime") {
            serverDate = Date.init(timeIntervalSince1970: TimeInterval(serverTime))
        }else{
            serverDate = Date()
        }
        source = data.debugDescription
        
   
    }
    
    var distanceTime: String {
        return Date().offset(from: serverDate)
    }
    
    var batteryString: String? {
        return battery != -1 ? "\(battery)%" : nil
    }
    
    var signalString: String? {
        return signal != -1 ? "\(signal)" : nil
    }
    
    static func == (lhs: GPSData, rhs: GPSData) -> Bool {
        return lhs.point == rhs.point && lhs.signal == rhs.signal && lhs.battery == rhs.battery
    }
}

enum EventType: Int {
    case unknown = 0, petRemoved, guestAdded, guestRemoved, guestLeft
    
    static func build(rawValue: Int) -> EventType {
        return EventType(rawValue: rawValue) ?? .unknown
    }
}

class Event{
    var type: EventType
    var pet: Pet?
    var guest: PetUser?
    
    init() {
        type = .unknown
        pet = nil
        guest = nil
    }    
}





























