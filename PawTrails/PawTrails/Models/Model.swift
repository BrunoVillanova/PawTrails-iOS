//
//  Models.swift
//  PawTrails
//
//  Created by Marc Perello on 26/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

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
enum PetSize: Int16 {
    case small, medium, large
    
    var description: String {
        switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
        }
    }
}

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
    var bcScore: Int
    var size: PetSize?

    var safezones: [SafeZone]?
    var users: [PetUser]?
}


enum TripPointStatus: Int {
    case started, paused, stopped, running
}

struct TripPoint {
    var timestamp: Int64
    var point: Point?
    var status: TripPointStatus?
}


struct Trip {
    var id: Int64
    var pet: Pet
    var petId: Int64
    var name: String?
    var status: Int16
    var startTimestamp: Int64?
    var stopTimestamp: Int64?
    var timestamp: Int64?
    var totalTime: Int64?
    var totalDistance: Int64?
    var averageSpeed: Float?
    var maxSpeed: Float?
    var steps: Int64?
    var points: [TripPoint]?
    var deviceData: [DeviceData]?
    var hasLocationData: Bool {
        get {
            if let tripsWithLocation = self.points?.filter({ (tripPoint) -> Bool in
                if let point = tripPoint.point, point.coordinates != nil {
                    return true
                } else {
                    return false
                }
            }), tripsWithLocation.count > 0 {
                return true
            } else {
                return false
            }
            
        }
    }
}


struct ActivityMonitor {
    var petId: Int
    var groupedBy: Int
    var activities: [Activities]?
 
}
struct Activities {
    var dateStart: Int
    var dateEnd: Int
    var chilling: Int
    var wandering: Int
    var lively: Int

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
    var image: Int16
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

struct DeviceData {
    var id: Int
    var point: Point?
    var speed: Float?
    var deviceTime: Int64?
    var deviceDate: Date?
    // LBS data
    var lbsTimestamp: Int64
    var batteryLevel: Int16
    var networkLevel: Int16
}

struct DeviceConnection {
    var statusTime: Int64
    var status: Int16
}

struct PetDeviceData {
    var id: Int
    var deviceData: DeviceData
    var pet: Pet
    var deviceConnection: DeviceConnection
}

struct TripAchievements {
    var petId: Int
    var distance: Int
    var timeGoal: Int
    var totalTime: Int
    var totalDistance: Int
    var totalDays: Int
}


struct DailyGoals {
    var petId: Int
    var distanceGoal: Int
    var timeGoal: Int
}


extension PetDeviceData: Equatable {
    static func == (lhs: PetDeviceData, rhs: PetDeviceData) -> Bool {
        return lhs.pet.id == rhs.pet.id && lhs.deviceData.deviceTime == rhs.deviceData.deviceTime
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
    
    var latitude: Double?
    var longitude: Double?
    
    var toDict: [String:Any]? {
        if let lat = latitude, let lon = longitude {
            return ["lat": lat, "lon":lon] as [String:Any]?
        }
        return nil
    }
    
    var toString: String {
        if let lat = latitude, let lon = longitude {
            return "\(lat) - \(lon)"
        }
        return "No location data"
    }
    
    override init() {
        latitude = nil
        longitude = nil
    }
    
    init(_ latitude: Double?, _ longitude: Double?) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ data:[String:Any]?) {
        
        if let lat = data?.tryCastDouble(for: "lat"), let lon = data?.tryCastDouble(for: "lon") {
            latitude = lat
            longitude = lon
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        if let lat = aDecoder.decodeObject(forKey: "latitude") as? Double, let lon =  aDecoder.decodeObject(forKey: "longitude") as? Double {
            latitude = lat
            longitude = lon
        }

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

extension Point {
    func getFullFormatedAddress(handler: @escaping (String?, Error?) -> Void) {
        
        guard self.latitude != nil && self.longitude != nil else {
            handler("No GPS position data", nil)
            return
        }
        
        
        if let lat = self.latitude, let lon = self.longitude {
            let location = CLLocation(latitude: lat, longitude: lon)
            let keyString = "\(lat),\(lon)"
            
            // Load from storage
            if let cachedAddress = try? CacheManager.sharedInstance.storage.object(ofType: String.self, forKey: keyString) {
                handler(cachedAddress, nil)
            } else {
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                    var address : String?
                    if let placemark = placemarks?[0] as CLPlacemark? {
                        if let formattedAddressLines = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                            address = formattedAddressLines.joined(separator: ", ")
                            try! CacheManager.sharedInstance.storage.setObject(address, forKey: keyString)
                        }
                    }
                    handler(address, error)
                })
            }
        }
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

