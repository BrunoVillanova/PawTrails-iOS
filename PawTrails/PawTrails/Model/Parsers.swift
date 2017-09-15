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
        image = nil
        imageURL = nil
        isOwner = false
        neutered =  false
        weight = nil
        safezones = nil
        users = nil
    }
    
    init(_ json: JSON) {
        id = json["id"].intValue
        deviceCode = json["device_code"].stringValue
        name = json["name"].string
        type = PetType(type: Type.build(code: json["type"].string), description: json["type_descr"].string)
        breeds = PetBreeds(json)
        gender = Gender.build(code: json["gender"].string)
        birthday = (json["date_of_birth"].string)?.toDate
        image = nil
        imageURL = json["img_url"].string
        isOwner = json["is_owner"].bool ?? false
        neutered = json["neutered"].bool ?? false
        weight = json["weight"].double
        safezones = nil
        users = nil
    }
    
    init(_ cdPet: CDPet) {
        id = Int(cdPet.id)
        deviceCode = cdPet.deviceCode
        name = cdPet.name
        type = PetType(type: Type(rawValue: cdPet.type), description: cdPet.type_descr)
        breeds = PetBreeds(cdPet.firstBreed, cdPet.secondBreed, cdPet.breed_descr)
        gender = Gender(rawValue: cdPet.gender)
        birthday = cdPet.birthday
        image = cdPet.image
        imageURL = cdPet.imageURL
        isOwner =  cdPet.isOwner
        neutered = cdPet.neutered
        weight = cdPet.weight
        safezones = (cdPet.safezones?.allObjects as? [CDSafeZone])?.map({ SafeZone($0) })
        users = (cdPet.users?.allObjects as? [CDPetUser])?.map({ PetUser($0) })
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



extension TripList {
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].string
        petId = json["petId"].intValue
        status = json["status"].intValue
        startTime = json["timeStart"].intValue
        stoppedTime = json["timeStop"].intValue
    }
}





extension Trip {
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].string
        petId = json["petId"].intValue
        status = json["status"].intValue
        timeStart = json["timeStart"].intValue
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
    }
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].string
        shape = Shape(rawValue: Int16(json["shape"].intValue)) ?? .circle
        active = json["active"].bool ?? false
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
    }
    
    var toDict: [String:Any] {
        var dict = [String:Any](object:self)
        dict["id"] = id == 0 ? nil : id
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


























