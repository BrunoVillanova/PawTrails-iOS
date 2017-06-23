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
            callback(DataManagerError(DBError: DatabaseError.IdNotFound), nil)
            return
        }
        
        APIManager.Instance.perform(call: .getUser, withKey: id) { (error, data) in
            self.handleUser(error, data, callback: callback)
        }
    }
    
    func set(image data:[String:Any]?, callback: @escaping errorCallback){
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            if let error = error {
                callback(DataManagerError.init(APIError: error))
            }else{
                callback(nil)
            }
        }
    }
    
    func save(user data:[String:Any], callback: @escaping userCallback) {
        
        APIManager.Instance.perform(call: .setUser, with: data) { (error, data) in
            self.handleUser(error, data, callback: callback)
        }
    }
    
    private func handleUser(_ error:APIManagerError?,_ data:[String:Any]?, callback: @escaping userCallback) {
        if error == nil, let data = data {
            self.setUser(data, callback: callback)
        }else if let error = error {
            callback(DataManagerError(APIError: error), nil)
        }else{
            debugPrint(error ?? "nil error", data ?? "nil data")
            callback(nil, nil)
        }
    }
    
    func removeUser() -> Bool {
        return AuthManager.Instance.isAuthenticated() && UserManager.remove()
    }
    
    func loadUserFriends(callback: @escaping petUsersCallback){
        APIManager.Instance.perform(call: .friends) { (error, data) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    PetUserManager.upsertFriends(data, callback: callback)
                }
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }else{
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil, nil)
            }
        }
    }

    // MARK: - Pet
    
    func addPetDB(_ data:[String:Any], callback: petCallback? = nil) {
        DispatchQueue.main.async {
            PetManager.upsert(data, callback: callback)
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
    
    func change(_ deviceCode: String, of petId:Int16, callback: @escaping errorCallback){
        var data = [String:Any]()
        data["device_code"] = deviceCode
        APIManager.Instance.perform(call: .changeDevice, withKey: petId, with: data)  { (error, data) in
            if let error = error {
                callback(DataManagerError(APIError: error))
            }else{
                callback(nil)
            }
        }
    }
    
    func register(pet data: [String:Any], callback: @escaping petCallback) {
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            if error == nil, let data = data {
                self.addPetDB(data, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }else{
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func getPet(_ petId:Int16, callback: @escaping petCallback) {
        DispatchQueue.main.async {
            PetManager.get(petId, callback)
        }
    }
    
    func loadPet(_ petId:Int16, callback: @escaping petCallback) {
        APIManager.Instance.perform(call: .getPet, withKey: petId) { (error, data) in
            if error == nil, let data = data {
                self.addPetDB(data, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }else{
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func removePet(_ petId: Int16, callback: @escaping errorCallback) {
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            if error == nil {
                self.removePetDB(petId, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }else{
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil)
            }
        }
    }
    
    func removePetDB(_ petId: Int16, callback: @escaping errorCallback) {
        DispatchQueue.main.async {
            if PetManager.remove(id: petId) {
                callback(nil)
            }else{
                callback(DataManagerError.init(DBError: DatabaseError.NotFound))
            }
        }
    }
    
    func getPets(callback: @escaping petsCallback) {
        PetManager.get(callback)
    }
    
    func getPetsSplitted(callback: @escaping petsSplittedCallback) {
        PetManager.get { (error, pets) in
            if error == nil, let pets = pets {
                let owned = pets.filter({ $0.isOwner == true })
                let shared = pets.filter({ $0.isOwner == false })
                callback(error, owned, shared)
            }else if let error = error {
                callback(error, nil, nil)
            }else{
                debugPrint(error ?? "nil error", pets ?? "nil pets")
                callback(nil, nil, nil)
            }
        }
    }
    
    func loadPets(callback: @escaping petsCallback) {
        checkBreeds()
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            if error == nil, let data = data {
                PetManager.upsertList(data, callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }else{
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func setPet(_ petId: Int16, _ data: [String:Any], callback: @escaping errorCallback){
        
        APIManager.Instance.perform(call: .setPet, withKey: petId, with: data)  { (error, data) in
            if error == nil, let data = data {
                self.addPetDB(data)
                callback(nil)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }else{
                print(error ?? "")
                print(data ?? "")
                callback(nil)
            }
        }
    }
    
    
    // MARK: - Pet Breeds
    
    func checkBreeds() {
        
        for type in [Type.cat, Type.dog] {
            
            getBreeds(for: type) { (error, breeds) in
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
                }else if let error = error {
                    callback(DataManagerError(APIError: error), nil)
                }else{
                    debugPrint(error ?? "", data ?? "")
                    callback(nil, nil)
                }
            })
        }else {
            callback(DataManagerError(DBError: DatabaseError.NotFound), nil)
        }
    }
    
    // MARK: - Pet Sharing
    
    func loadPetFriends(callback: @escaping petUsersCallback){
        
        APIManager.Instance.perform(call: .friends) { (error, data) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    PetUserManager.upsertFriends(data, callback: callback)
                }
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }else {
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func getPetFriends(for pet: Pet, callback: @escaping petUsersCallback){
        PetUserManager.getFriends { (error, friends) in
            if let error = error {
                callback(error, nil)
            }else if let friends = friends, let users = pet.users?.allObjects as? [PetUser]{
                callback(nil, friends.filter({ !users.contains($0) }))
            }
        }
    }
    
    func loadSharedPetUsers(for petId: Int16, callback: petUsersCallback?) {
        APIManager.Instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil) { (error, data) in
            if error == nil, let data = data, let callback = callback {
                DispatchQueue.main.async {
                    PetUserManager.upsertList(data, into: petId, callback: callback)
                }
            }else if let error = error, let callback = callback {
                callback(DataManagerError(APIError: error), nil)
            }else if let callback = callback {
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func addSharedUser(by data: [String:Any], to petId: Int16, callback: @escaping petUsersCallback) {
        APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
            if error == nil, let data = data {
                self.addSharedUserDB(with: data, to: petId, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }else{
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil, nil)
            }
        }
    }
    
    func addSharedUserDB(with data: [String:Any], to petId: Int16, callback: @escaping petUsersCallback){
        DispatchQueue.main.async {
            PetUserManager.upsert(data, into: petId, callback: callback)
        }
    }
    
    func removeSharedUser(by data: [String:Any], to petId: Int16, callback: @escaping errorCallback) {
        APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: data) { (error, data) in
            if error == nil {
                callback(nil)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    func removeSharedUserDB(id: Int16, from petId:Int16, callback: @escaping errorCallback){
        DispatchQueue.main.async {
            PetUserManager.removeSharedUser(with: id, from: petId, callback: callback)
        }
    }
    
    func leaveSharedPet(by petId: Int16, callback: @escaping errorCallback) {
        APIManager.Instance.perform(call: .leaveSharedPet, withKey: petId) { (error, data) in
            if error == nil {
                callback(nil)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    // MARK: - Pet Safe Zones
    
    func loadSafeZones(of petId:Int16, callback: @escaping errorCallback) {
        
        APIManager.Instance.perform(call: .listSafeZones, withKey: petId) { (error, data) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    SafeZoneManager.upsertList(data, into: petId)
                    callback(nil)
                }
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }else {
                debugPrint(error ?? "nil error", data ?? "nil data")
                callback(nil)
            }
        }
    }
    
    func addSafeZone(by data: [String:Any], to petId: Int16, callback: @escaping safezoneCallback) {
        APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
            if error == nil, let data = data {
                DispatchQueue.main.async {
                    SafeZoneManager.upsert(data, callback: callback)
                }
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }
        }
    }
    
    func setSafeZone(by data: [String:Any], to petId: Int16, callback: @escaping errorCallback) {
        APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    func setSafeZoneStatus(enabled: Bool,for id: Int16, into petId: Int16, callback: @escaping errorCallback) {
        let data: [String:Any] = ["id":id, "active":enabled]
        APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    func removeSafeZone(by safezoneId: Int16, to petId: Int16, callback: @escaping errorCallback) {
        APIManager.Instance.perform(call: .removeSafeZone, withKey: safezoneId) { (error, data) in
            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
//    func setSafeZone(_ safezone: SafeZone, imageData:Data){
//        SafeZoneManager.set(safezone: safezone, imageData: imageData)
//    }
//    
//    func setSafeZone(_ safezone: SafeZone, address:String){
//        SafeZoneManager.set(safezone: safezone, address: address)
//    }
    
    func setSafeZone(imageData:Data, for id: Int16){
        SafeZoneManager.set(imageData: imageData, for: id)
    }
    
    func setSafeZone(address:String, for id: Int16){
        SafeZoneManager.set(address: address, for: id)
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



