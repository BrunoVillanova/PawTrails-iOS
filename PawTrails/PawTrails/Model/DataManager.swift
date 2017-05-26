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
    
    func setUser(_ data: [String:Any], callback: userCallback? = nil){
        DispatchQueue.main.async {
            UserManager.upsert(data, callback: callback)
        }
    }
    
    func getUser(callback:@escaping userCallback){
        DispatchQueue.main.async {
            UserManager.get(callback)
        }
    }
    
    func loadUser(callback:@escaping userCallback) {
        
        guard let id = SharedPreferences.get(.id) else {
            callback(UserError.IdNotFound, nil)
            return
        }
        
        APIManager.Instance.perform(call: .getUser, withKey: id) { (error, data) in
            if error == nil, let data = data {
                self.setUser(data)
                self.getUser(callback: callback)
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
                self.setUser(data)
                self.getUser(callback: callback)
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
    
    func loadUserFriends(callback: @escaping petUsersCallback){
        APIManager.Instance.perform(call: .friends) { (error, data) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    PetUserManager.upsertFriends(data)
                    PetUserManager.getFriends(callback: callback)
                }
            }
        }
    }
    
    // MARK: - Pet
    
    private func setPet(_ data:[String:Any], callback: petCallback? = nil) {
        DispatchQueue.main.async {
            PetManager.upsertPet(data, callback: callback)
        }
    }
    
    func check(_ deviceCode: String, callback: @escaping petCheckDeviceCallback){
        APIManager.Instance.perform(call: .checkDevice, withKey: deviceCode) { (error, data) in
            if error == nil, let data = data, let available = data["available"] as? Bool {
                callback(available)
            }else{
                callback(false)
            }
        }
    }
    
    func change(_ deviceCode: String, of petId:Int16, callback: @escaping petErrorCallback){
        var data = [String:Any]()
        data["device_code"] = deviceCode
        APIManager.Instance.perform(call: .changeDevice, withKey: petId, with: data)  { (error, data) in
            //            if error == nil {
            //                if PetManager.removePet(id: petId) {
            //                    callback(nil)
            //                }else{
            //                    callback(PetError.PetNotFoundInDataBase)
            //
            //                }
            //            }else{
            //                callback(PetError.PetNotFoundInResponse)
            //            }
        }
    }
    
    func register(pet data: [String:Any], callback: @escaping petCallback) {
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            if error == nil, let data = data {
                self.setPet(data, callback: callback)
            }else{
                print("Error registerin pet \(String(describing: error))")
                callback(PetError.IdNotFound, nil)
            }
        }
    }
    
    func getPet(_ petId:Int16, callback: @escaping petCallback) {
        DispatchQueue.main.async {
            PetManager.getPet(petId, callback)
        }
    }
    
    func loadPet(_ petId:Int16, callback: @escaping petCallback) {
        APIManager.Instance.perform(call: .getPet, withKey: petId) { (error, data) in
            if error == nil, let data = data {
                self.setPet(data, callback: callback)
            }
        }
    }
    
    func removePet(_ petId: Int16, callback: @escaping petErrorCallback) {
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            if error == nil {
                DispatchQueue.main.async {
                    if PetManager.removePet(id: petId) {
                        callback(nil)
                    }else{
                        callback(PetError.PetNotFoundInDataBase)
                        
                    }
                }
            }else{
                callback(PetError.PetNotFoundInResponse)
            }
        }
    }
    
    func getPets(callback: @escaping petsCallback) {
        PetManager.getPets(callback)
    }
    
    func getPetsSplitted(callback: @escaping petsSplittedCallback) {
        PetManager.getPets { (error, pets) in
            if let pets = pets {
                let owned = pets.filter({ $0.isOwner == true })
                let shared = pets.filter({ $0.isOwner == false })
                callback(error, owned, shared)
            }else{
                callback(error, nil, nil)
            }
        }
    }
    
    func loadPets(callback: @escaping petsCallback) {
        checkBreeds()
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            if error == nil, let data = data {
                PetManager.upsertPets(data, callback)
            }else{
                callback(PetError.PetsNotFoundInResponse, nil)
            }
        }
    }
    
    func setPet(_ petId: Int16, _ data: [String:Any], callback: @escaping petErrorCallback){
        
        APIManager.Instance.perform(call: .setPet, withKey: petId, with: data)  { (error, data) in
            if error == nil, let data = data {
                self.setPet(data)
                callback(nil)
            }else{
                callback(PetError.PetNotFoundInResponse)
            }
        }
    }
    
    
    // MARK: - Pet Breeds
    
    func checkBreeds() {
        
        for type in [Type.cat, Type.dog] {
            
            BreedManager.retrieve(for: type) { (error, breeds) in
                if breeds == nil { self.loadBreeds(for: type, callback: { (_, _) in })}
            }
        }
    }
    
    
    func getBreeds(for type: Type, callback: @escaping breedsCallback) {
        BreedManager.retrieve(for: type, callback: callback)
    }
    
    func loadBreeds(for type: Type, callback: @escaping breedsCallback) {
        
        if type == .cat || type == .dog {
            
            APIManager.Instance.perform(call: .getBreeds, withKey: type.code, completition: { (error, data) in
                if error == nil, let data = data {
                    DispatchQueue.main.sync {
                        BreedManager.upsert(data, for: type, callback: callback)
                    }
                }
            })
        }
    }
    
    // MARK: - Pet Sharing
    
    func loadPetFriends(callback: @escaping petUsersCallback){
        
        APIManager.Instance.perform(call: .friends) { (error, data) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    PetUserManager.upsertFriends(data)
                    PetUserManager.getFriends(callback: callback)
                }
            }
        }
    }
    
    func getPetFriends(callback: @escaping petUsersCallback){
        PetUserManager.getFriends(callback: callback)
    }
    
    func loadSharedPetUsers(for petId: Int16, callback: petUsersCallback?) {
        APIManager.Instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil) { (error, data) in
            if error == nil, let data = data, let callback = callback {
                DispatchQueue.main.async {
                    PetUserManager.upsert(data, into: petId)
                    PetUserManager.get(for: petId, callback: callback)
                }
            }else if let callback = callback {
                callback(PetError.IdNotFound, nil)
            }
        }
    }
    
    func addSharedUser(by data: [String:Any], to petId: Int16, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
            if error == nil {
                self.loadSharedPetUsers(for: petId, callback: { (error, pet) in
                    callback(error)
                })
            }
        }
    }
    
    func removeSharedUser(by data: [String:Any], to petId: Int16, callback: @escaping petErrorCallback) {
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
    
    func leaveSharedPet(by petId: Int16, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .leaveSharedPet, withKey: petId) { (error, data) in
            if error == nil {
                callback(nil)
            }else{
                callback(PetError.MoreThenOnePet)
            }
        }
    }
    
    // MARK: - Pet Safe Zones
    
    func loadSafeZones(of petId:Int16, callback: @escaping petErrorCallback) {
        
        APIManager.Instance.perform(call: .listSafeZones, withKey: petId) { (error, data) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    SafeZoneManager.upsertList(data, into: petId)
                    callback(nil)
                }
            }else{
                callback(PetError.IdNotFound)
            }
        }
    }
    
    func addSafeZone(by data: [String:Any], to petId: Int16, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }
        }
    }
    
    func setSafeZone(by data: [String:Any], to petId: Int16, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else{
                callback(PetError.MoreThenOnePet)
            }
        }
    }
    
    func setSafeZoneStatus(enabled: Bool,for id: Int16, into petId: Int16, callback: @escaping petErrorCallback) {
        let data: [String:Any] = ["id":id, "active":enabled]
        APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else{
                callback(PetError.MoreThenOnePet)
            }
        }
    }
    
    func removeSafeZone(by safezoneId: Int16, to petId: Int16, callback: @escaping petErrorCallback) {
        APIManager.Instance.perform(call: .removeSafeZone, withKey: safezoneId) { (error, data) in
            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else{
                callback(PetError.MoreThenOnePet)
            }
        }
    }
    
    func setSafeZone(_ safezone: SafeZone, imageData:Data){
        SafeZoneManager.set(safezone: safezone, imageData: imageData)
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



