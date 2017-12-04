//
//  Parsers.swift
//  PawTrails
//
//  Created by Marc Perello on 26/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK:- User

extension Authentication {
    
    init(_ json: JSON) {
        token = json["token"].string
        socialNetwork = SocialMedia(rawValue: json["social_network"].string ?? "")
        user = User(json["user"])
    }
    
}



extension User {
    
    init() {
        id = -1
        name = nil
        surname = nil
        email = nil
        notification = false
        birthday = nil
        gender = nil
        imageURL = nil
        image = nil
        address = nil
        phone = nil
        friends = nil
    }
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].string
        surname = json["surname"].string
        email = json["email"].string
        notification = json["notification"].bool ?? false
        birthday = (json["date_of_birth"].string)?.toDate
        gender = Gender.build(code: json["gender"].string)
        imageURL = json["img_url"].string
        image = nil
        address = json["address"].exists() ? Address(json["address"]) : nil
        phone = json["mobile"].exists() ? Phone(json["mobile"]) : nil
        friends = nil
    }
    
    init?(_ cdUser: CDUser) {
        
        id = Int(cdUser.id)
        name = cdUser.name
        surname = cdUser.surname
        email = cdUser.email
        notification = cdUser.notification
        birthday = cdUser.birthday
        gender = Gender(rawValue: cdUser.gender)
        imageURL = cdUser.imageURL
        image = cdUser.image as Data?
        address = cdUser.address != nil ? Address(cdUser.address!) : nil
        phone = cdUser.phone != nil ? Phone(cdUser.phone!) : nil
        friends = (cdUser.friends?.allObjects as? [CDPetUser])?.map({ PetUser($0)})
        
    }
    
    var toDict: [String:Any] {
        var dict = [String:Any](object:self)
        dict["id"] = id == 0 ? nil : id
        dict["date_of_birth"] = birthday?.toStringServer ?? ""
        dict["gender"] = gender?.code ?? ""
        
        dict["mobile"] = phone?.toDict
        dict["address"] = address?.toDict
        
        dict.filter(by: ["image", "imageURL", "birthday", "friends", "phone"])
        return dict
    }
}

extension Address {
    
    init(_ json: JSON) {
        city = json["city"].string
        country = json["country"].string
        line0 = json["line0"].string
        line1 = json["line1"].string
        line2 = json["line2"].string
        postalCode = json["postal_code"].string
        state = json["state"].string
    }
    
    init(_ cdAddress: CDAddress) {
        
        city = cdAddress.city
        country = cdAddress.country
        line0 = cdAddress.line0
        line1 = cdAddress.line1
        line2 = cdAddress.line2
        postalCode = cdAddress.postal_code
        state = cdAddress.state
    }
    
    var toDict: [String:Any] {
        var dict = [String:Any](object:self)
        dict["postal_code"] = postalCode ?? ""
        dict.filter(by: ["postalCode"])
        return dict
    }
    
}

extension Phone {
    
    init(_ json: JSON) {
        number = json["number"].string
        countryCode = json["country_code"].string
    }
    
    init(_ cdPhone: CDPhone) {
        number = cdPhone.number
        countryCode = cdPhone.country_code
    }
    
    var toDict: [String:Any] {
        var dict = [String:Any](object:self)
        dict["country_code"] = countryCode ?? ""
        dict.filter(by: ["countryCode"])
        return dict
    }
}

//MARK:- Pet

extension Pet {

    init() {
        id = 0
        deviceCode = ""
        name = nil
        type = nil
        breeds = nil
        gender = nil
        birthday = nil
        image = UIImagePNGRepresentation(#imageLiteral(resourceName: "PetPlaceholderImage"))
        imageURL = nil
        isOwner = false
        neutered =  false
        weight = nil
        safezones = nil
        users = nil
        bcScore = 0
        size = 0
    }
    
    init(_ id: Int) {
        self.init()
        self.id = id
    }
    
    init(_ json: JSON) {
        id = json["id"].intValue
        deviceCode = json["device_code"].stringValue
        name = json["name"].string
        type = PetType(type: Type.build(code: json["type"].string), description: json["type_descr"].string)
        breeds = PetBreeds(json)
        gender = Gender.build(code: json["gender"].string)
        birthday = (json["date_of_birth"].string)?.toDate
        image = UIImagePNGRepresentation(#imageLiteral(resourceName: "PetPlaceholderImage"))
        imageURL = json["img_url"].string
        isOwner = json["is_owner"].bool ?? false
        neutered = json["neutered"].bool ?? false
        weight = json["weight"].double
        safezones = nil
        users = nil
        bcScore = json["bcScore"].intValue
        size = json["size"].intValue
    }
    
    init(_ cdPet: CDPet) {
        id = Int(cdPet.id)
        deviceCode = cdPet.deviceCode
        name = cdPet.name
        type = PetType(type: Type(rawValue: cdPet.type), description: cdPet.type_descr)
        breeds = PetBreeds(cdPet.firstBreed, cdPet.secondBreed, cdPet.breed_descr)
        gender = Gender(rawValue: cdPet.gender)
        birthday = cdPet.birthday
        image = cdPet.image != nil ? cdPet.image : UIImagePNGRepresentation(#imageLiteral(resourceName: "PetPlaceholderImage"))
        imageURL = cdPet.imageURL
        isOwner =  cdPet.isOwner
        neutered = cdPet.neutered
        weight = cdPet.weight
        safezones = (cdPet.safezones?.allObjects as? [CDSafeZone])?.map({ SafeZone($0) })
        users = (cdPet.users?.allObjects as? [CDPetUser])?.map({ PetUser($0) })
        bcScore = Int(cdPet.bcScore)
        size = Int(cdPet.size)
    }
    
    var toDict: [String:Any] {
        var dict = [String:Any](object:self)
        dict["id"] = id == 0 ? nil : id
        dict["device_code"] = deviceCode
        dict["date_of_birth"] = birthday?.toStringServer
        dict["type"] = type?.type?.code
        dict["type_descr"] = type?.description
        dict["gender"] = gender?.code
        dict["breed"] = breeds?.breeds[0]
        dict["breed1"] = breeds?.breeds[1]
        dict["breed_descr"] = breeds?.description
        dict["weight"] = weight != 0.0 ? weight : nil
        dict["bcScore"] = bcScore == 0 ? nil : bcScore
        dict["size"] = size == 0 ? nil : size
        dict.filter(by: ["image", "imageURL", "birthday", "safezones", "users", "breeds", "isOwner", "deviceCode"])
        return dict
    }
}

extension PetBreeds {
    
    init(_ json: JSON) {
        breeds = [Int?](repeating: nil, count: 2)
        breeds[0] = json["breed"].int
        breeds[1] = json["breed1"].int
        first = nil
        second = nil
        description = json["breed_descr"].string
    }
    
    init(_ first: CDBreed?, _ second: CDBreed?, _ breedDescription: String?) {
        breeds = [Int?](repeating: nil, count: 2)
        self.first = nil
        self.second = nil
        if let first = first {
            breeds[0] = first.id.toInt
            self.first = Breed(first)
        }
        if let second = second {
            breeds[1] = second.id.toInt
            self.second = Breed(second)
        }
        description = breedDescription
    }
    
    init(first: Breed?, second: Breed?, _ breedDescription: String?) {
        breeds = [Int?](repeating: nil, count: 2)
        self.first = nil
        self.second = nil
        if let first = first {
            breeds[0] = first.id
            self.first = first
        }
        if let second = second {
            breeds[1] = second.id
            self.second = second
        }
        description = breedDescription
    }

}

extension PetDeviceData {
    init() {
        id = 0
        deviceData = DeviceData()
        pet = Pet()
    }
    
    init(_ json: [String:Any]) {
        id = 0
        deviceData = DeviceData()
        
        if json["deviceData"] != nil {
            deviceData = DeviceData(json["deviceData"] as! [String:Any])
            id = deviceData.id
        }
        
        if let petID = json["petId"] as? Int {
            if let storedPet = CoreDataManager.instance.retrieve(.pet, with: NSPredicate("id", .equal, petID))?.first as! CDPet? {
                pet = Pet(storedPet)
            } else {
                pet = Pet(petID)
            }
        } else {
            pet = Pet()
        }
    }
    
    static func fromJson(_ json: Any?) -> [PetDeviceData]? {
        var petDeviceDataList : [PetDeviceData]?
        if let jsonValues = json as? [Any]!, jsonValues.count > 0 {
            petDeviceDataList = [PetDeviceData]()
            for petDeviceDataObject in jsonValues {
                if let petDeviceDataJson = petDeviceDataObject as? [String:Any] {
                    let petDeviceData = PetDeviceData(petDeviceDataJson)
                    petDeviceDataList!.append(petDeviceData)
                }
            }
        }
        
        return petDeviceDataList
    }
    
    init(_ cdPetDeviceData: CDPetDeviceData) {
        deviceData = DeviceData(cdPetDeviceData)
        id = deviceData.id
        if let pets = CoreDataManager.instance.retrieve(.pet, with: NSPredicate("id", .equal, id)) {
            pet = Pet(pets.first as! CDPet)
        } else {
            pet = Pet()
        }
    }
}

extension DeviceData {
    
    init() {
        id = 0
        crs = 0.0
        point = Point()
        speed = 0.0
        battery = 0
        internetSignal = false
        satelliteSignal = false
        deviceTime = 0
        deviceDate = Date()
    }
    
    init(_ json: [String:Any]) {
        id = json["idpos"] != nil ? json["idpos"] as! Int : 0
        crs = json["crs"] as! Float
        point = Point(json["lat"] as! Double, json["lon"] as! Double)
        speed = json["speed"] as! Float
        battery = json["battery"] as! Int16
        internetSignal = json["netSignal"] as! Bool
        satelliteSignal = json["satSignal"] as! Bool
        deviceTime = json["deviceTime"] as! Int64
        deviceDate = Date.init(timeIntervalSince1970: TimeInterval(json["deviceTime"] as! Int))
    }
    
    init(_ cdPetDeviceData: CDPetDeviceData) {
        id = Int(cdPetDeviceData.id)
        crs = cdPetDeviceData.crs
        point = Point(cdPetDeviceData.latitude, cdPetDeviceData.longitude)
        speed = cdPetDeviceData.speed
        battery = Int16(cdPetDeviceData.battery)
        internetSignal = cdPetDeviceData.netSignal
        satelliteSignal = cdPetDeviceData.satSignal
        deviceTime = cdPetDeviceData.deviceTime
        deviceDate = Date.init(timeIntervalSince1970: TimeInterval(cdPetDeviceData.deviceTime))
    }
}

extension Breed {
    
    init(_ json: JSON, _ _type: Type) {
        id = json["id"].intValue
        name = json["name"].stringValue
        type = _type
    }
    
    init(_ cdBreed: CDBreed) {
        id = Int(cdBreed.id)
        name = cdBreed.name ?? ""
        type = Type(rawValue: cdBreed.type) ?? .other
    }
}

extension PetUser {
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].string
        surname = json["surname"].string
        isOwner = json["is_owner"].bool ?? false
        email = json["email"].string
        imageURL = json["img_url"].string
        image = nil
    }
    
    init(_ cdPetUser: CDPetUser) {
        id = Int(cdPetUser.id)
        name = cdPetUser.name
        surname = cdPetUser.surname
        isOwner = cdPetUser.isOwner
        email = cdPetUser.email
        imageURL = cdPetUser.imageURL
        image = cdPetUser.image
    }
}

extension DailyGoals {
    init(_ json: JSON) {
        petId = json["petId"].intValue
        distanceGoal = json["distanceGoal"].intValue
        timeGoal = json["timeGoal"].intValue
    }
}



extension TripList {
    init(_ json: JSON) {
        id = json["id"].intValue
        petId = json["petId"].intValue
        name = json["name"].string
        status = json["status"].intValue
        startTime = json["timeStart"].intValue
        stoppedTime = json["timeStop"].intValue
    }
}

extension TripAchievements {
    init(_ json: JSON) {
        petId = json["petId"].intValue
        distance = json["distanceGoal"].intValue
        timeGoal = json["timeGoal"].intValue
        totalTime = json["totalTime"].intValue
        totalDistance = json["totalDistance"].intValue
        totalDays = json["totalDays"].intValue
    }
}


extension Trip {
    init(_ values: [String:Any]) {
        // Required
        id = values["id"] as! Int64
        petId = values["petId"] as! Int64
        name = values["name"] as! String?
        status = values["status"] as! Int16
        startTimestamp = values["timeStart"] as! Int64?
        // Optional
        stopTimestamp = values["timeStop"] as? Int64
        timestamp = values["timeStamp"] as? Int64
        totalTime = values["totalTime"] as? Int64
        totalDistance = values["totalDistance"] as? Int64
        averageSpeed = values["averageSpeed"] as? Float
        maxSpeed = values["maxSpeed"] as? Float
        steps = values["steps"] as? Int64
        points = [TripPoint]()
        
        if let pointsValues = values["rawData"] as! [[Any]]? {
            for pointValue in pointsValues {
                if let pointArray = pointValue as [Any]! {
                    points!.append(TripPoint(pointArray))
                }
            }
        }
        
        if let petID = values["petId"] as? Int {
            if let storedPet = CoreDataManager.instance.retrieve(.pet, with: NSPredicate("id", .equal, petID))?.first as! CDPet? {
                pet = Pet(storedPet)
            } else {
                pet = Pet(petID)
            }
        } else {
            pet = Pet()
        }
    }
    
    init(_ json: JSON) {
        // Required
        id = json["id"].int64Value
        petId = json["petId"].int64Value
        name = json["name"].stringValue
        status = json["status"].int16Value
        startTimestamp = json["timeStart"].int64Value
        // Optional
        stopTimestamp = json["timeStop"].int64
        timestamp = json["timeStamp"].int64
        totalTime = json["totalTime"].int64
        totalDistance = json["totalDistance"].int64
        averageSpeed = json["averageSpeed"].float
        maxSpeed = json["maxSpeed"].float
        steps = json["steps"].int64
        points = [TripPoint]()
        pet = Pet()

        if let pointsValues = json["rawData"].arrayObject as! [[Any]]! {
            for pointValue in pointsValues {
                if let pointArray = pointValue as [Any]! {
                    points!.append(TripPoint(pointArray))
                }
            }
        }
        
        if let petID = json["petId"].int, let storedPet = CoreDataManager.instance.retrieve(.pet, with: NSPredicate("id", .equal, petID))?.first as! CDPet? {
            pet = Pet(storedPet)
        }
    }
}


extension TripPoint {
    init(_ json: [Any]) {
        // Required
        timestamp = 0
        point = Point()
        
        if let jsonArray = json as [Any]!  {
            timestamp = Int64(jsonArray[0] as! Int)
            let latitudeValue = jsonArray[1]
            let longitudeValue = jsonArray[2]
            
            if !(latitudeValue is NSNull) && !(longitudeValue is NSNull) {
                point = Point(latitudeValue as! Double, longitudeValue as! Double)
            }
            
        }
    }
}

extension SafeZone {
    
    init() {
        id = 0
        name = nil
        shape = Shape.circle
        active = false
        point1 = nil
        point2 = nil
        address = nil
        preview = nil
        image = 0
    }
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].string
        shape = Shape(rawValue: Int16(json["shape"].intValue)) ?? .circle
        active = json["active"].bool ?? false
        image = Int16(json["class"].intValue)
        point1 = Point(json["point1"].dictionaryObject)
        point2 = Point(json["point2"].dictionaryObject)
        address = nil
        preview = nil
    }
    
    init(_ cdSafezone: CDSafeZone) {
        id = Int(cdSafezone.id)
        name = cdSafezone.name
        shape = Shape(rawValue: cdSafezone.shape) ?? .circle
        active = cdSafezone.active
        point1 = cdSafezone.point1
        point2 = cdSafezone.point2
        address = cdSafezone.address
        preview = cdSafezone.preview
        image = cdSafezone.image
    }
    
    var toDict: [String:Any] {
        var dict = [String:Any](object:self)
        dict["id"] = id == 0 ? nil : id
        dict["class"] = image
        dict["shape"] = shape.code
        dict["point1"] = point1?.toDict ?? ""
        dict["point2"] = point2?.toDict ?? ""
        dict.filter(by: ["preview", "address"])
        return dict
    }
}



extension CountryCode {
    
    init(_ cdCountryCode: CDCountryCode) {
        code = cdCountryCode.code
        name = cdCountryCode.name
        shortName = cdCountryCode.shortName
    }
    
    init?(_ stringRow: [String]) {
        if stringRow.count == 3 {
            name = stringRow[0]
            shortName = stringRow[1]
            code = stringRow[2]
        }else{
            name = nil
            shortName = nil
            code = nil
        }
    }
    
    var toDict: [String:Any] {
        var dict = [String:Any](object:self)
        dict["name"] = name
        dict["shortName"] = shortName
        dict["code"] = code
        return dict
    }
    
    var isNotNil: Bool {
        return name != nil && code != nil && shortName != nil
    }
}


//MARK:- Helpers

extension Event {
    
    convenience init(_ json: JSON) {
        self.init()
        if let id = json["ope"].int {
            type = EventType.build(rawValue: id)
        }
        
        if json["pet"].exists() {
            pet = Pet(json["pet"])
        }
        
        if json["guest"].exists() {
            guest = PetUser(json["guest"])
        }
    }
    
}


























