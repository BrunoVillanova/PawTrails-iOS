//
//  APIRepository.swift
//  PawTrails
//
//  Created by Marc Perello on 26/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SwiftyJSON
import FirebaseMessaging

/// Communicates with *APIManager* to perform all REST API calls.
class APIRepository {
    
    /// Shared Instance
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
    typealias ApiTrip = (APIManagerError?, [Trip]?) -> Void
    typealias ApiTripListCallBack = (APIManagerError?, [Trip]?) -> Void
    typealias ApiGetAchievmenetCallBack = (APIManagerError?, TripAchievements?) -> Void
    typealias ApiGetDailyGoalCallBack = (APIManagerError?, DailyGoals?) -> Void
    typealias ApiGetActivityMonitorCallBack = (APIManagerError? , ActivityMonitor?) -> Void
    
    
    //MARK:- Authentication
    
    
    /// Register a new user
    ///
    /// - Parameters:
    ///   - email: new user email
    ///   - password: new user password
    ///   - callback: returns the **authentication information** or **error**
    func signUp(_ email:String, _ password: String, callback: @escaping APIRepAuthCallback) {
        
        var cloudNotification = [String:Any]()
        
        if let token = Messaging.messaging().fcmToken {
            cloudNotification = [
                "envType": 1,
                "deviceType": 2,
                "token": token
            ]
        }
        
        var data : [String:Any] = ["email":email, "password": password, "cloudNoti": cloudNotification]
        
        if isDebug {
            data["is4test"] = ezdebug.is4test
        }
        
        APIManager.instance.perform(call: .signUp, with: data) { (error, json) in
            if let error = error {
                callback(error, nil)
            }else if let json = json {
                callback(nil, Authentication(json))
            }
        }
    }
    
    /// Logs in a current user
    ///
    /// - Parameters:
    ///   - email: current user email
    ///   - password: current user password
    ///   - callback: returns the **authentication information** or **error**
    func signIn(_ email:String, _ password: String, callback: @escaping APIRepAuthCallback) {
       
        var cloudNotification = [String:Any]()
        
        if let token = Messaging.messaging().fcmToken {
            cloudNotification = [
                "envType": 1,
                "deviceType": 2,
                "token": token
            ]
        }
        
        var data : [String:Any] = ["email":email, "password": password, "cloudNoti": cloudNotification]
        
        if isDebug {
            data["is4test"] = ezdebug.is4test
        }
        
        APIManager.instance.perform(call: .signIn, with: data) { (error, json) in
            if let error = error {
                callback(error, nil)
            }else if let json = json {
                callback(nil, Authentication(json))
            }
        }
    }
    
    /// Use social media as a way to register/login in the application
    ///
    /// - Parameters:
    ///   - socialMedia: specific social media channel used
    ///   - token: social media token provided
    ///   - callback: returns the **authentication information** or **error**
    func login(socialMedia: SocialMedia, _ token: String, callback: @escaping APIRepAuthCallback){
        
        var cloudNotification = [String:Any]()
        
        if let token = Messaging.messaging().fcmToken {
            cloudNotification = [
                "envType": 1,
                "deviceType": 2,
                "token": token
            ]
        }
        
        var data: [String : Any] = ["loginToken" : token, "itsIOS": socialMedia == .google ? 1 : "", "cloudNoti": cloudNotification]
        
        if isDebug {
            data["is4test"] = ezdebug.is4test
        }
        
        APIManager.instance.perform(call: APICallType(socialMedia), with: data) { (error, json) in
            if let error = error {
                callback(error, nil)
            }else if let json = json {
                callback(nil, Authentication(json))
            }
        }
    }
    
    /// Send a reset password email to the address provided
    ///
    /// - Parameters:
    ///   - email: current user email password reset process target.
    ///   - callback: returns **nil** or **error**
    func sendPasswordReset(_ email:String, callback: @escaping APIRepErrorCallback) {
        
        let data:[String : Any] = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]
        
        APIManager.instance.perform(call: .passwordReset, with: data) { (error, data) in
            callback(error)
        }
    }
    
    /// Attempts to set a new password for a current user
    ///
    /// - Parameters:
    ///   - id: current user id
    ///   - email: current user email
    ///   - password: current user password
    ///   - newPassword: new user password
    ///   - callback: returns **nil** or **error**
    func changeUsersPassword(_ id: Int, _ email:String, _ password:String, _ newPassword:String, callback: @escaping APIRepErrorCallback) {
        
        let data:[String : Any] = ["id": id, "email":email, "password":password, "new_password":newPassword]
        
        APIManager.instance.perform(call: .passwordChange, with: data) { (error, data) in
            callback(error)
        }
    }
    
    //MARK:- User
    
    /// Collects the user information
    ///
    /// - Parameters:
    ///   - id: user id
    ///   - callback: returns the **user information** or **error**
    func loadUser(by id: Int, callback:@escaping APIRepUserCallback) {
        
        APIManager.instance.perform(call: .getUser, withKey: id) { (error, data) in
            self.handleUser(error, data, callback: callback)
        }
    }
    
    /// Saves user
    ///
    /// - Parameters:
    ///   - user: user object with information to update
    ///   - callback: returns the **updated user** or **error**
    func save(_ user: User, callback: @escaping APIRepUserCallback) {
        
        APIManager.instance.perform(call: .setUser, with: user.toDict) { (error, data) in
            self.handleUser(error, data, callback: callback)
        }
    }
    
    /// Saves user image
    ///
    /// - Parameters:
    ///   - image: data containing new image in JPG format
    ///   - id: user id
    ///   - callback: returns **nil** or **error**
    func saveUser(_ image: Data, by id: Int, callback: @escaping APIRepErrorCallback) {
        
        let data = ["path" : "user", "userid" : id, "picture" : image ] as [String : Any]
        
        setImage(with: data, callback: callback)
    }
    
    /// Saves user notification value
    ///
    /// - Parameters:
    ///   - status: value: Enabled/Disbled
    ///   - id: user id
    ///   - callback: returns **nil** or **error**
    func saveUserNotification(_ status: Bool, by id: Int, callback: @escaping APIRepErrorCallback) {
        
        let data = ["id" : id, "notification" : status ] as [String : Any]
        
        APIManager.instance.perform(call: .setUser, with: data) { (error, _) in
            callback(error)
        }
    }
    
    private func handleUser(_ error:APIManagerError?,_ json:JSON?, callback: @escaping APIRepUserCallback) {
        if error == nil, let json = json {
            callback(nil, User(json))
        }else if let error = error {
            callback(error, nil)
        }
    }
    
    // MARK: - Pet
    
    /// Checks if the device is available
    ///
    /// - Parameters:
    ///   - deviceCode: code provided of the device
    ///   - callback: returns whether the device is idle or not
    func check(_ deviceCode: String, callback: @escaping APIRepCheckDeviceCallback){
        let data = ["code" : deviceCode]
        APIManager.instance.perform(call: .checkDevice, with: data) { (error, data) in
            if error == nil {
                callback(nil, data?["available"].bool ?? false)
            } else if let error = error {
                callback(error, false)
            }
        }

    }
    
    /// Attempts to replace pet device
    ///
    /// - Parameters:
    ///   - deviceCode: new device code
    ///   - petId: target pet id to change device
    ///   - callback: returns **nil** or **error**
    func change(_ deviceCode: String, of petId:Int, callback: @escaping APIRepErrorCallback){
        
        let data = ["device_code" : deviceCode ]
        
        APIManager.instance.perform(call: .changeDevice, withKey: petId, with: data)  { (error, data) in
            callback(error)
        }
    }
    
 
    
    
    
    
    /// Register a new pet
    ///
    /// - Parameters:
    ///   - pet: new pet information to add
    ///   - callback: returns the **new added pet** or **error**
    func register(pet: Pet, callback: @escaping APIRepPetCallback) {
        
        APIManager.instance.perform(call: .registerPet, with: pet.toDict) { (error, json) in
            if error == nil, let json = json {
                var pet = Pet(json)
                pet.isOwner = true
                callback(nil, pet)
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    /// Collects the pet information
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: returns the **pet information** or **error**
    func loadPet(_ petId:Int, callback: @escaping APIRepPetCallback) {
        
        APIManager.instance.perform(call: .getPet, withKey: petId) { (error, json) in
            if error == nil, let json = json {
                callback(nil, Pet(json))
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    /// Removes pet
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: returns **nil** or **error**
    func removePet(_ petId: Int, callback: @escaping APIRepErrorCallback) {
        
        APIManager.instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            callback(error)
        }
    }

    
    /// Collect all shared and owned user pets
    ///
    /// - Parameter callback: return the **pets** or **error**
    func loadPets(callback: @escaping APIRepPetsCallback) {

        APIManager.instance.perform(call: .getPets) { (error, json) in
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
            }
        }
    }
    
    /// Save pet
    ///
    /// - Parameters:
    ///   - pet: pet object with new updates
    ///   - callback: returns the updated **pet** or the **error* ocurred
    func save(_ pet: Pet, callback: @escaping APIRepPetCallback){
        
        APIManager.instance.perform(call: .setPet, withKey: pet.id, with: pet.toDict)  { (error, json) in
            if error == nil, let json = json {
                callback(nil, Pet(json))
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    /// Saves pet image
    ///
    /// - Parameters:
    ///   - image: data containing new image in JPG format
    ///   - id: pet id
    ///   - callback: returns **nil** or **error**
    func savePet(_ image: Data, by id: Int, callback: @escaping APIRepErrorCallback) {
        
        let data = ["path":"pet","petid":id,"picture":image] as [String : Any]
        
        setImage(with: data, callback: callback)
    }
    
    //MARK:- User and Pet
    
    private func setImage(with data:[String:Any]?, callback: @escaping APIRepErrorCallback){
        
        APIManager.instance.perform(call: .imageUpload, with: data) { (error, data) in
            callback(error)
        }
    }

    // MARK: - Pet Breeds
    
    /// Collects all breads
    ///
    /// - Parameters:
    ///   - type: pet type
    ///   - callback: return the **breeds** or **error**
    func loadBreeds(for type: Type, callback: @escaping APIRepBreedsCallback) {
        
        APIManager.instance.perform(call: .getBreeds, withKey: type.code, callback: { (error, json) in
            if error == nil, let breedsJson = json?["breeds"].array {
                var breeds = [Breed]()
                for breedJson in breedsJson {
                    breeds.append(Breed(breedJson, type))
                }
                callback(nil, breeds)
            }else if let error = error {
                callback(error, nil)
            }
        })
    }

    // MARK: - Pet Sharing
    
    /// Collect pet friends
    ///
    /// - Parameter callback: returns friends or **error**
    func loadPetFriends(callback: @escaping APIRepPetUsersCallback){
        
        APIManager.instance.perform(call: .friends) { (error, json) in
            if error == nil, let friendsJson = json?["friendlist"].array {
                var friends = [PetUser]()
                for friendJson in friendsJson {
                    friends.append(PetUser(friendJson))
                }
                callback(nil, friends)
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    /// Collects pet shared users
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: returns **shared users** or **error**
    func loadSharedPetUsers(for petId: Int, callback: @escaping APIRepPetUsersCallback) {
       
        APIManager.instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil) { (error, json) in
            if error == nil, let usersJson = json?["users"].array {
                var users = [PetUser]()
                for userJson in usersJson {
                    users.append(PetUser(userJson))
                }
                callback(nil, users)
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    /// Add new shared user to pet by email
    ///
    /// - Parameters:
    ///   - email: new shared user email
    ///   - petId: pet id
    ///   - callback: return added **shared user** or **error**
    func addSharedUser( by email: String, to petId: Int, callback: @escaping APIRepPetUserCallback) {
        
        let data: [String:Any] = ["email": email]
        
        APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, json) in
            if error == nil, let json = json {
                callback(nil, PetUser(json))
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    /// Removes shared user
    ///
    /// - Parameters:
    ///   - id: user id to remove
    ///   - petId: pet id
    ///   - callback: returns **nil** or **error**
    func removeSharedUser(by id: Int, from petId: Int, callback: @escaping APIRepErrorCallback) {
        
        let data: [String:Any] = ["user_id": id]
        
        APIManager.instance.perform(call: .removeSharedPet, withKey: petId, with: data) { (error, _) in
            callback(error)
        }
    }
    
    /// Removes current shared user
    ///
    /// - Parameters:
    ///   - id: user id to remove
    ///   - petId: pet id
    ///   - callback: returns **nil** or **error**
    func leaveSharedPet(by petId: Int, callback: @escaping APIRepErrorCallback) {
        APIManager.instance.perform(call: .leaveSharedPet, withKey: petId) { (error, _) in
            callback(error)
        }
    }

    // MARK: - Pet Safe Zones
    
    /// Collects SafeZones of a pet
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: returns **safezones** or **error**
    func loadSafeZones(of petId:Int, callback: @escaping APIRepPetSafeZonesCallback) {
        APIManager.instance.perform(call: .listSafeZones, withKey: petId) { (error, json) in
            if error == nil, let safezonesJson = json?["safezones"].array {
                var safezones = [SafeZone]()
                for safezoneJson in safezonesJson {
                    safezones.append(SafeZone(safezoneJson))
                }
                callback(nil, safezones)
            }else if let error = error {
                callback(error, nil)
            }
        }
    }
    
    /// Add new safezone
    ///
    /// - Parameters:
    ///   - safezone: safezone information
    ///   - petId: pet id
    ///   - callback: returns **safezone added** or **error**
    func add(_ safezone: SafeZone, to petId: Int, callback: @escaping APIRepPetSafeZoneCallback) {
        
        var dict = safezone.toDict
        dict["petid"] = petId
        
        APIManager.instance.perform(call: .addSafeZone, with: dict) { (error, json) in
            if error == nil, let json = json {
                callback(nil, SafeZone(json))
            }
        }
    }
    
    /// Save safezone
    ///
    /// - Parameters:
    ///   - safezone: safezone with updates
    ///   - petId: pet id
    ///   - callback: returns updated **safezone** or **error**
    func save(_ safezone: SafeZone, to petId: Int, callback: @escaping APIRepErrorCallback) {
        APIManager.instance.perform(call: .setSafeZone, with: safezone.toDict) { (error, _) in
            callback(error)
        }
    }
    
    /// Save safezone status
    ///
    /// - Parameters:
    ///   - status: value enabled/disabled
    ///   - id: safezone id
    ///   - petId: pet id
    ///   - callback: returns updated **safezone** or **error**
    func setSafeZone(status: Bool,for id: Int, into petId: Int, callback: @escaping APIRepErrorCallback) {
        
        let data: [String:Any] = ["id":id, "active":status]
        
        APIManager.instance.perform(call: .setSafeZone, with: data) { (error, _) in
            callback(error)
        }
    }
    
    /// Remove safezone
    ///
    /// - Parameters:
    ///   - safezoneId: safezone id
    ///   - petId: pet id
    ///   - callback: returns **nil** or **error**
    func removeSafeZone(by safezoneId: Int, to petId: Int, callback: @escaping APIRepErrorCallback) {
        
        APIManager.instance.perform(call: .removeSafeZone, withKey: safezoneId) { (error, data) in
            callback(error)
        }
    }
    
    
    // Start Trip
    /// Partmeters
    ////   - PetId/s
    // callBack: returns nil or data
    

    func startTrips(_ petIdss: [Int], callback: @escaping ApiTrip) {
        let data = ["pets":petIdss]
        APIManager.instance.perform(call: .startTrip, with: data) { (error, json) in
            if let error = error {
                callback(error, nil)
            } else if let myData = json?["trips"].array {
                var tripArray = [Trip]()
                for trip in myData {
                    tripArray.append(Trip(trip))
                }
                callback(nil, tripArray)
                
            }
            
        }
    }

    func getTripList(_ status: [Int], callback: @escaping ApiTrip) {
        
        let dataa = ["status":status]
        APIManager.instance.perform(call: .getTripList, with: dataa) { (error, json) in
            if error == nil, let tripListJson = json?["trips"].array {
                var tripList = [Trip]()
                for trip in tripListJson {
                    tripList.append(Trip(trip))
                }
                 callback(nil, tripList)
            } else if let error = error {
                callback(error, nil)
            }
        }
    }

    // Finish Trips
    // callBack: returns nil or data
    func finishTrip(_ tripIDs: [Int], callback: @escaping ApiTrip) {
        let data: [String: Any] = ["trips": tripIDs, "timeStamp": Int(Date().timeIntervalSince1970)]
        APIManager.instance.perform(call: .finishTrip, with: data) { (error, json) in
            if error == nil, let tripListJson = json?["trips"].array {
                var tripList = [Trip]()
                for trip in tripListJson {
                    tripList.append(Trip(trip))
                }
                callback(nil, tripList)
            } else if let error = error {
                callback(error, nil)
            }
        }
        }

    
    // Pause Trips
    // callBack: returns nil or data
    func pauseTrip(_ tripIDs: [Int], callback: @escaping APIRepErrorCallback) {
        let data: [String: Any] = ["trips": tripIDs, "timeStamp": Int(Date().timeIntervalSince1970)]
        APIManager.instance.perform(call: .pauseTrip, with: data) { (error, json) in
            if let error = error {
                callback(error)
            }
        }
    }
    
    
    // Resume trips
    //callBack: returns nil or data
    func resumeTrip(callBack: @escaping APIRepErrorCallback) {
        APIManager.instance.perform(call: .resumeTrip) { (error, json) in
            callBack(error)
        }
    }
    
    // Delete trip
    //callBack: returns nil or error
    func deleteTrip(_ tripID: Int, callBack: @escaping APIRepErrorCallback) {
        APIManager.instance.perform(call: .deleteTrip, withKey: tripID) { (error, json) in
            callBack(error)
        }
    }
    
    // Get pet trip achievements
    //callBack: returns nil or error
    func getPetTripAchievements(_ petId: Int, from: Int, to: Int, status: [Int], callback: @escaping ApiGetAchievmenetCallBack) {
        var achievments: [String:Any] {
            var dict = [String:Any](object:self)
            dict["from"] = from
            dict["to"] = to
            dict["petId"] = petId
            dict["status"] = status
            return dict
        }
        
        APIManager.instance.perform(call: .getTripsAchievements, with: achievments) { (error, json) in
            if error == nil, let achievmeentsJson = json {
                callback(nil, TripAchievements(achievmeentsJson))
            } else if let error = error {
                callback(error, nil)
            }
        }
        
    }
    
    
    func getDailyGoals(_ petId: Int, callback: @escaping ApiGetDailyGoalCallBack) {
        var petId: [String:Any] {
            var dict = [String:Any](object:self)
            dict["petId"] = petId
            return dict
        }
        APIManager.instance.perform(call: .getDailyGoals, with: petId) { (error, json) in
            if error == nil, let dailyGoal = json {
                callback(nil, DailyGoals(dailyGoal))
            } else {
                callback(error, nil)
                
            }
        }
        
    }
    
    
    func editTripDailyGoal(_ petId: Int, distanceGoal: Int, timeGoal: Int, callback: @escaping APIRepErrorCallback) {
        var goal: [String:Any] {
            var dict = [String:Any](object:self)
            dict["petId"] = petId
            dict["distanceGoal"] = distanceGoal
            dict["timeGoal"] = timeGoal
            return dict
        }
        APIManager.instance.perform(call: .editDailyGoal, with: goal) { (json, error) in
            callback(json)
        }
    }
    
    func getActivityMonitorData (_ petId: Int, startDate: Int, endDate: Int, groupedBy: Int, callback: @escaping ApiGetActivityMonitorCallBack) {
        var activity: [String:Any] {
            var dict = [String:Any](object:self)
            dict["petId"] = petId
            dict["dateStart"] = startDate
            dict["dateEnd"] = endDate
            dict["groupBy"] = groupedBy
            return dict
        }
        APIManager.instance.perform(call: .activityMonitor, with: activity) { (error, json) in
            if error == nil, let json = json {
                
                var myactivities = [Activities]()
                let petId = json["petId"].intValue
                let groupedBy = json["groupBy"].intValue
                guard let activities = json["activities"].array else {return}
                for activityy in activities {
                    myactivities.append(Activities(activityy))
                }
                let activity = ActivityMonitor.init(petId: petId, groupedBy: groupedBy, activities: myactivities)
                callback(nil, activity)
                
//
            } else if let error = error {
                callback(error, nil)

            }
        }
        
    }
    
    func logout(callback: @escaping APIRepErrorCallback) {
     
        APIManager.instance.perform(call: .logout) { (error, json) in
            if error == nil {
                callback(nil)
            } else if let error = error {
                callback(error)
            }
        }
    }
    func getImmediateLocation(_ petIdss: [Int], callback: @escaping APIRepErrorCallback) {
         let petIds = ["ids":petIdss]
        APIManager.instance.perform(call: .getImmediateLocation, with: petIds) { (error, json) in
            if let error = error {
                callback(error)
            } else {
                callback(nil)
            }
        }
    }
}
















