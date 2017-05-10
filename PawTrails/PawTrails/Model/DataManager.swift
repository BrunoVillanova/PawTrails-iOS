//
//  UserManager.swift
//  PawTrails
//
//  Created by Marc Perello on 07/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class DataManager {
    
    static let Instance = DataManager()
    
    // MARK: - User
    
    func setUser(_ data: [String:Any]){
        UserManager.upsert(data)
    }
    
    func getUser(callback:@escaping userCallback){
        UserManager.get(callback)
    }
    
    func loadUser(callback:@escaping userCallback) {
        
        APIManager.Instance.perform(call: .getUser, withKey: SharedPreferences.get(.id)!) { (error, data) in
            if error == nil, let data = data {

                UserManager.upsert(data)
                UserManager.get(callback)
            }else{
                print(error ?? "")
                print(data ?? "")
                // check db first and the
                 callback(UserError.UserNotFound, nil)
            }
        }
    }
        
    func set(image data:[String:Any]?, callback: @escaping ((Bool)->())){
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            callback(error == nil)
        }
    }
    
    func set(user data:[String:Any], callback: @escaping userCallback) {
        
        APIManager.Instance.perform(call: .setUser, with: data) { (error, data) in
            if error == nil, let data = data {
                
                UserManager.upsert(data)
                UserManager.get(callback)
            }else{
                print(error ?? "")
                print(data ?? "")
                // check db first and the
                callback(UserError.UserNotFound, nil)
            }
        }
    }
    
    func removeUser() -> Bool {
        if AuthManager.Instance.isAuthenticated() {
            return UserManager.remove()
        }
        return true
    }
    
    func getUserFriends(){
        
    }
    
    // MARK: - Pet
    
    func check(_ deviceCode: String, callback: @escaping petCheckDeviceCallback){
        APIManager.Instance.perform(call: .checkDevice, withKey: deviceCode) { (error, data) in
            if error == nil, let data = data {
                if let available = data["available"] as? Bool {
                    callback(available)
                    return
                }
            }
            callback(false)
        }
    }
    
    func change(_ deviceCode: String, of petId:String, callback: @escaping petErrorCallback){
        var data = [String:Any]()
        data["device_code"] = deviceCode
        APIManager.Instance.perform(call: .changeDevice, withKey: petId, with: data)  { (error, data) in
            if error == nil {
                if PetManager.removePet(id: petId) {
                    callback(nil)
                }else{
                    callback(PetError.PetNotFoundInDataBase)
                    
                }
            }else{
                callback(PetError.PetNotFoundInResponse)
            }
        }
    }
    
    func register(pet data: [String:Any], callback: @escaping petCallback) {
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            if error == nil, let data = data {
                PetManager.upsertPet(data, callback: callback)
            }else{
                print("Error registerin pet \(String(describing: error))")
                callback(PetError.IdNotFound, nil)
            }
        }
    }
    
    func getPet(_ petId:String, callback: @escaping petCallback) {
        PetManager.getPet(petId, callback)
    }
    
    func loadPet(_ petId:String, callback: @escaping petCallback) {
        APIManager.Instance.perform(call: .getPet, withKey: petId) { (error, data) in
            if error == nil, let data = data {
                PetManager.upsertPet(data)
                PetManager.getPet(petId, callback)
            }
        }
    }
    
    func removePet(_ petId: String, callback: @escaping petErrorCallback) {
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            if error == nil {
                if PetManager.removePet(id: petId) {
                    callback(nil)
                }else{
                    callback(PetError.PetNotFoundInDataBase)
                    
                }
            }else{
                callback(PetError.PetNotFoundInResponse)
            }
        }
    }
    
    func getPets(callback: @escaping petsCallback) {
        PetManager.getPets(callback)
    }
    
    func loadPets(callback: @escaping petsCallback) {
        BreedManager.check()
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            if error == nil, let data = data {
                PetManager.upsertPets(data, callback)
            }else{
                callback(PetError.PetsNotFoundInResponse, nil)
            }
        }
    }
    
    func setPet(_ petId: String, _ data: [String:Any], callback: @escaping petErrorCallback){
        
        APIManager.Instance.perform(call: .setPet, withKey: petId, with: data)  { (error, data) in
            if error == nil, let data = data {
                PetManager.upsertPet(data)
                print("done saving")
                callback(nil)
            }else{
                callback(PetError.PetNotFoundInResponse)
            }
        }
    }
    
    
    // MARK: - Pet Breeds

    func getBreeds(for type: Type, callback: @escaping breedsCallback) {
        BreedManager.retrieve(for: type, callback: callback)
    }
    
    func loadBreeds(for type: Type, callback: @escaping breedsCallback) {
        BreedManager.load(for: type, callback: callback)
    }
    
    
    
    // MARK: - Pet Sharing

    func loadPetFriends(callback: @escaping petUsersCallback){
        
        APIManager.Instance.perform(call: .friends) { (error, data) in
            if error == nil, let data = data {
                PetUserManager.upsertFriends(data)
                PetUserManager.getFriends(callback: callback)
            }
        }
        
        PetUserManager.getFriends(callback: callback)
    }
    
    func getPetFriends(callback: @escaping petUsersCallback){
        PetUserManager.getFriends(callback: callback)
    }
    
    func loadSharedPetUsers(for petId: String, callback: petUsersCallback?) {
        APIManager.Instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil) { (error, data) in
            if error == nil, let data = data, let callback = callback {
                PetUserManager.upsert(data, into: petId)
                PetUserManager.get(for: petId, callback: callback)
            }else if let callback = callback {
                callback(PetError.IdNotFound, nil)
            }
        }
    }
    
    func addSharedUser(by data: [String:Any], to petId: String, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
            if error == nil {
                self.loadSharedPetUsers(for: petId, callback: { (error, pet) in
                    callback(error)
                })
            }
        }
    }
    
    func removeSharedUser(by data: [String:Any], to petId: String, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: data) { (error, data) in
            if error == nil {
                self.loadSharedPetUsers(for: petId, callback: { (error, pet) in
                    callback(error)
                })
            }else{
                callback(PetError.MoreThenOnePet)
            }
        }
    }
    
    func leaveSharedPet(by petId: String, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .leaveSharedPet, withKey: petId) { (error, data) in
            if error == nil {
                self.loadSharedPetUsers(for: petId, callback: { (error, pet) in
                    callback(error)
                })
            }else{
                callback(PetError.MoreThenOnePet)
            }
        }
    }
    
    // MARK: - Tracking
    
    func trackingIsIdle() -> Bool {
        return SocketIOManager.Instance.isConnected()
    }
    
    func startTracking(pet:Pet, callback: @escaping petTrackingCallback){
        // Send RQ to API which provides channel and verification?
        
        //        guard let name = pet.name else {
        //            fatalError()
        //        }
        
        if !trackingIsIdle() {return}
        
//        let name = pet.name
//        SocketIOManager.Instance.launch(name: name)
//        SocketIOManager.Instance.listen(name: name, { (lat, long) in
//            //set last location
//            callback((lat, long))
//        })
    }
    
    func stopTracking(pet:Pet){
        // Stop live tracking
        
        if !trackingIsIdle() {return}
        
//        let name = pet.name
        
//        SocketIOManager.Instance.stop(name: name)
    }
    
    
    // MARK: - Country Codes
    
    func getCountryCodes() -> [CountryCode]? {
        return CountryCodeManager.getAll()
    }
    
    func getCurrentCountryShortName() -> String {
        return CountryCodeManager.getCurrent() ?? "IE"
    }
    

    // MARK: - Search
    
    /**
     First request search to local storage whilst performs a call to the REST API to update information, once the information is updated it callsback the information.
     
     - Parameter text: Search text.
     - Parameter callback: Returns the updated information.
     - Parameter data: .

     - Returns: The local information available.
     */
    func performSearch(_ text:String, callback:(_ data:[String]) -> Swift.Void) -> [String] {
        
        // RQ
        
        
//        callback(AddressManager.search(text))
        //return AddressManager.search(text)
        return [String]()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}



