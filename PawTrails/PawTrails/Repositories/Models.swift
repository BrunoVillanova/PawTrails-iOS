//
//  Models.swift
//  PawTrails
//
//  Created by Marc Perello on 26/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

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































