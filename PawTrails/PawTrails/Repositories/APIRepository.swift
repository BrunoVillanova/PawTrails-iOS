//
//  APIRepository.swift
//  PawTrails
//
//  Created by Marc Perello on 26/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIRepository {
    
    static let instance = APIRepository()
    
    typealias APIRepErrorCallback = (APIManagerError?) -> Void
    typealias APIRepAuthCallback = (_ error: APIManagerError?, _ auth:Authentication?) -> Void
    typealias APIRepUserCallback = (APIManagerError?, User?) -> Void
    typealias APIRepCheckDeviceCallback = (APIManagerError?, Bool) -> Void
    typealias APIRepPetCallback = (APIManagerError?, Pet?) -> Void
    typealias APIRepPetsCallback = (APIManagerError?, [Pet]?) -> Void
    typealias APIRepBreedsCallback = (APIManagerError?, [Breed]?) -> Void
    typealias APIRepPetUserCallback = (APIManagerError?, PetUser?) -> Void
    typealias APIRepPetUsersCallback = (APIManagerError?, [PetUser]?) -> Void
    typealias APIRepPetSafeZoneCallback = (APIManagerError?, SafeZone?) -> Void
    typealias APIRepPetSafeZonesCallback = (APIManagerError?, [SafeZone]?) -> Void
    
    //MARK:- Authentication
    
    
    func signUp(_ email:String, _ password: String, callback: @escaping APIRepAuthCallback) {
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        
        APIManager.Instance.perform(call: .signUp, with: data) { (error, json) in
            if let error = error {
                callback(error, nil)
            }else if let json = json {
                callback(nil, Authentication(json))
            }
        }
    }
    
    func signIn(_ email:String, _ password: String, callback: @escaping APIRepAuthCallback) {
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        
        APIManager.Instance.perform(call: .signIn, with: data) { (error, json) in
            if let error = error {
                callback(error, nil)
            }else if let json = json {
                callback(nil, Authentication(json))
            }
        }
    }
    
    func login(socialMedia: SocialMedia, _ token: String, callback: @escaping APIRepAuthCallback){
        
        let data: [String : Any] = ["loginToken" : token, "itsIOS": socialMedia == .google ? 1 : ""]
        
        APIManager.Instance.perform(call: APICallType(socialMedia), with: data) { (error, json) in
            if let error = error {
                callback(error, nil)
            }else if let json = json {
                callback(nil, Authentication(json))
            }
        }
    }
    
    func sendPasswordReset(_ email:String, callback: @escaping APIRepErrorCallback) {
        
        let data:[String : Any] = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]
        
        APIManager.Instance.perform(call: .passwordReset, with: data) { (error, data) in
            callback(error)
        }
    }
    
    func changeUsersPassword(_ id: Int, _ email:String, _ password:String, _ newPassword:String, callback: @escaping APIRepErrorCallback) {
        
        let data:[String : Any] = ["id": id, "email":email, "password":password, "new_password":newPassword]
        
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            callback(error)
        }
    }
    
    //MARK:- User
    
    func loadUser(by id: Int, callback:@escaping APIRepUserCallback) {
        
        APIManager.Instance.perform(call: .getUser, withKey: id) { (error, data) in
            self.handleUser(error, data, callback: callback)
        }
    }
    
    func save(_ user: User, callback: @escaping APIRepUserCallback) {
        
        APIManager.Instance.perform(call: .setUser, with: user.toDict) { (error, data) in
            self.handleUser(error, data, callback: callback)
        }
    }
    
    func saveUser(_ image: Data, by id: Int, callback: @escaping APIRepErrorCallback) {
        
        let data = ["path" : "user", "userid" : id, "picture" : image ] as [String : Any]
        
        setImage(with: data, callback: callback)
    }
    
    func saveUserNotification(_ status: Bool, by id: Int, callback: @escaping APIRepErrorCallback) {
        
        let data = ["id" : id, "notification" : status ] as [String : Any]
        
        APIManager.Instance.perform(call: .setUser, with: data) { (error, _) in
            callback(error)
        }
    }
    
    private func handleUser(_ error:APIManagerError?,_ json:JSON?, callback: @escaping APIRepUserCallback) {
        if error == nil, let json = json {
            callback(nil, User(json))
        }else if let error = error {
            callback(error, nil)
        }else{
            debugPrint(error ?? "nil error", json ?? "nil data")
            callback(nil, nil)
        }
    }
    
    // MARK: - Pet
    
    func check(_ deviceCode: String, callback: @escaping APIRepCheckDeviceCallback){
        
        APIManager.Instance.perform(call: .checkDevice, withKey: deviceCode) { (error, data) in
            if error == nil {
                callback(nil, data?["available"].bool ?? false)
            }else if let error = error {
                callback(error, false)
            }else{
                callback(nil, false)
            }
        }
    }
    
    func change(_ deviceCode: String, of petId:Int, callback: @escaping APIRepErrorCallback){
        
        let data = ["device_code" : deviceCode ]
        
        APIManager.Instance.perform(call: .changeDevice, withKey: petId, with: data)  { (error, data) in
            callback(error)
        }
    }
    
    func register(pet: Pet, callback: @escaping APIRepPetCallback) {
        
        APIManager.Instance.perform(call: .registerPet, with: pet.toDict) { (error, json) in
            if error == nil, let json = json {
                var pet = Pet(json)
                pet.isOwner = true
                callback(nil, pet)
            }else if let error = error {
                callback(error, nil)
            }else{
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func loadPet(_ petId:Int, callback: @escaping APIRepPetCallback) {
        
        APIManager.Instance.perform(call: .getPet, withKey: petId) { (error, json) in
            if error == nil, let json = json {
                callback(nil, Pet(json))
            }else if let error = error {
                callback(error, nil)
            }else{
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func removePet(_ petId: Int, callback: @escaping APIRepErrorCallback) {
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            callback(error)
        }
    }

    func loadPets(callback: @escaping APIRepPetsCallback) {

        APIManager.Instance.perform(call: .getPets) { (error, json) in
            if error == nil {
                var pets = [Pet]()
                if let petsJson = json?["pets"].array {
                    for petJson in petsJson {
                        pets.append(Pet(petJson))
                    }
                }
                callback(nil, pets)
            }else if let error = error {
                callback(error, nil)
            }else{
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func save(_ pet: Pet, callback: @escaping APIRepPetCallback){
        
        APIManager.Instance.perform(call: .setPet, withKey: pet.id, with: pet.toDict)  { (error, json) in
            if error == nil, let json = json {
                callback(nil, Pet(json))
            }else if let error = error {
                callback(error, nil)
            }else if let error = error {
                callback(error, nil)
            }else{
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func savePet(_ image: Data, by id: Int, callback: @escaping APIRepErrorCallback) {
        
        let data = ["path":"pet","petid":id,"picture":image] as [String : Any]
        
        setImage(with: data, callback: callback)
    }
    
    //MARK:- User and Pet
    
    private func setImage(with data:[String:Any]?, callback: @escaping APIRepErrorCallback){
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            callback(error)
        }
    }

    // MARK: - Pet Breeds
    
    func loadBreeds(for type: Type, callback: @escaping APIRepBreedsCallback) {
        
        APIManager.Instance.perform(call: .getBreeds, withKey: type.code, callback: { (error, json) in
            if error == nil, let breedsJson = json?["breeds"].array {
                var breeds = [Breed]()
                for breedJson in breedsJson {
                    breeds.append(Breed(breedJson, type))
                }
                callback(nil, breeds)
            }else if let error = error {
                callback(error, nil)
            }else{
                debugPrint(error ?? "", json ?? "")
                callback(nil, nil)
            }
        })
    }

    // MARK: - Pet Sharing
    
    func loadPetFriends(callback: @escaping APIRepPetUsersCallback){
        
        APIManager.Instance.perform(call: .friends) { (error, json) in
            if error == nil, let friendsJson = json?["friendlist"].array {
                var friends = [PetUser]()
                for friendJson in friendsJson {
                    friends.append(PetUser(friendJson))
                }
                callback(nil, friends)
            }else if let error = error {
                callback(error, nil)
            }else {
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func loadSharedPetUsers(for petId: Int, callback: @escaping APIRepPetUsersCallback) {
       
        APIManager.Instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil) { (error, json) in
            if error == nil, let usersJson = json?["users"].array {
                var users = [PetUser]()
                for userJson in usersJson {
                    users.append(PetUser(userJson))
                }
                callback(nil, users)
            }else if let error = error {
                callback(error, nil)
            }else {
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func addSharedUser( by email: String, to petId: Int, callback: @escaping APIRepPetUserCallback) {
        
        let data: [String:Any] = ["email": email]
        
        APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, json) in
            if error == nil, let json = json {
                callback(nil, PetUser(json))
            }else if let error = error {
                callback(error, nil)
            }else{
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func removeSharedUser(by id: Int, from petId: Int, callback: @escaping APIRepErrorCallback) {
        
        let data: [String:Any] = ["user_id": id]
        
        APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: data) { (error, _) in
            callback(error)
        }
    }
    
    func leaveSharedPet(by petId: Int, callback: @escaping APIRepErrorCallback) {
        
        APIManager.Instance.perform(call: .leaveSharedPet, withKey: petId) { (error, _) in
            callback(error)
        }
    }

    // MARK: - Pet Safe Zones
    
    func loadSafeZones(of petId:Int, callback: @escaping APIRepPetSafeZonesCallback) {
        
        APIManager.Instance.perform(call: .listSafeZones, withKey: petId) { (error, json) in
            if error == nil, let safezonesJson = json?["safezones"].array {
                var safezones = [SafeZone]()
                for safezoneJson in safezonesJson {
                    safezones.append(SafeZone(safezoneJson))
                }
                callback(nil, safezones)
            }else if let error = error {
                callback(error, nil)
            }else {
                debugPrint(error ?? "nil error", json ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func add(_ safezone: SafeZone, to petId: Int, callback: @escaping APIRepPetSafeZoneCallback) {
        
        var dict = safezone.toDict
        dict["petid"] = petId
        
        APIManager.Instance.perform(call: .addSafeZone, with: dict) { (error, json) in
            if error == nil, let json = json {
                callback(nil, SafeZone(json))
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    func save(_ safezone: SafeZone, to petId: Int, callback: @escaping APIRepErrorCallback) {
        
        APIManager.Instance.perform(call: .setSafeZone, with: safezone.toDict) { (error, _) in
            callback(error)
        }
    }
    
    func setSafeZone(status: Bool,for id: Int, into petId: Int, callback: @escaping APIRepErrorCallback) {
        
        let data: [String:Any] = ["id":id, "active":status]
        
        APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, _) in
            callback(error)
        }
    }
    
    func removeSafeZone(by safezoneId: Int, to petId: Int, callback: @escaping APIRepErrorCallback) {
        
        APIManager.Instance.perform(call: .removeSafeZone, withKey: safezoneId) { (error, data) in
            callback(error)
        }
    }

}
