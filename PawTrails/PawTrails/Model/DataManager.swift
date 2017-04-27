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
        APIManager.Instance.perform(call: .imageUpload) { (error, data) in
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
    
//    func set(image data:[String:Any]?, callback: ((Bool)->())){
//        APIManager.Instance.perform(call: .userImageUpload) { (error, data) in
//            callback(error == nil)
//        }
//    }
//    
//    func set(user data:[String:Any], imageData: [String:Any]?, callback: @escaping userCallback) {
//       
////        if let imageData = imageData {
////            
////            var data = [String:Any]()
////            data["path"] = "user"
////            data["userid"] = user.id
////            data["picture"] = imageData
////            
////            APIManager.Instance.perform(call: .userImageUpload, with: data, completition: { (error, data) in
////                if error == nil && data != nil {
////                    self.saveUser(user: user, phone: phone, address: address, callback: callback)
////                }else{
////                    self.handeUser(with: error, data, callback)
////                }
////            })
////            
////        }else{
////            saveUser(user: user, phone: phone, address: address, callback: callback)
////        }
//    }
    
//    fileprivate func saveUser(user:User, phone:[String:Any]?, address:[String:Any]?, callback: @escaping userCallback){
//        APIManager.Instance.perform(call: .setUser, with: UserManager.parse(user, phone, address)) { (error, data) in
//            if error == nil && data != nil {
//                self.handleUser(with: data, callback)
//            }else{
//                self.handeUser(with: error, data, callback)
//            }
//        }
//    }
    
    func removeUser() -> Bool {
        if AuthManager.Instance.isAuthenticated() {
            return UserManager.remove()
        }
        return true
    }
    
    // MARK: - Pet
    
    func check(_ deviceCode: String, callback: @escaping petCheckDeviceCallback){
        APIManager.Instance.perform(call: .checkDevice, withKey: deviceCode) { (error, data) in
            if error == nil, let data = data {
                if let available = data["available"] as? Int {
                    callback(available == 1)
                }
            }
            callback(false)
        }
    }
    
    func getPet(_ petId:Int, callback: @escaping petCallback) {
        
//        APIManager.Instance.perform(call: .getPet) { (error, data) in
//            if error == nil && data != nil {
//                
//            }else{
//                
//            }
//        }
        PetManager.getPet(petId, callback)
    }
    
    func removePet(_ petId: String) -> Bool {
       return PetManager.removePet(id: petId)
    }
    
    func getPets(callback: @escaping petsCallback) {
        
//        APIManager.Instance.perform(call: .getPets) { (error, data) in
//            if error == nil && data != nil {
//                
//            }else{
//                
//            }
//        }

        PetManager.getPets(callback)
    }
    
    func setPet(_ data: [String:Any], callback: @escaping petErrorCallback){
        
        APIManager.Instance.perform(call: .setPet, with: data) { (error, data) in
            if error == nil, let data = data {
                PetManager.upsertPet(data)
            }
        }
        
        
        callback(nil)
    }
    
    func getPetFriends(callback: @escaping petUsersCallback){
        
        // API Call??
        PetManager.getFriends(callback: callback)
    }
    
    func getBreeds(for type: Type, withUpdate: Bool = true, callback: @escaping breedCallback) {
        
        if withUpdate {
            BreedManager.get(for: type, callback: { (error, breeds) in
                if error == nil, let breeds = breeds {
                    callback(nil, breeds)
                }else{
                    BreedManager.retrieve(for: type, callback: callback)
                }
            })
        }else{
            BreedManager.retrieve(for: type, callback: callback)
        }
    }
    
    func loadBreeds(for type: Type) {
        BreedManager.get(for: type, callback: { (_, _) in })
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



