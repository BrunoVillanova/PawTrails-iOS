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
   
    func getUser(withUpdate: Bool = true, callback:@escaping userCallback) {
        
        if AuthManager.Instance.isAuthenticated() {
            
            if withUpdate {
                loadUser(callback: callback)
            }else{
                UserManager.get(callback)
            }
        }else{
            callback(UserError.NotAuthenticated, nil)
        }
    }
    
    private func loadUser(callback:@escaping userCallback) {
        
        APIManager.Instance.perform(call: .getUser) { (error, data) in
            if error == nil && data != nil {
                self.handleUser(with: data, callback)
            }else{
                self.handeUser(with: error, data, callback)
            }
        }
    }
    
    private func handleUser(with data:[String:Any]?, _ callback:@escaping userCallback) {
//        guard let userData = data!["user"] as? [String:Any] else {
//            debugPrint("User not found in json \(data)")
//            return
//        }
        guard let userData = data else {
            debugPrint("User not found in json \(String(describing: data))")
            callback(UserError.UserNotFoundInResponse, nil)
            return
        }
        UserManager.upsert(userData)
        UserManager.get(callback)
    }
    
    private func handeUser(with error:APIManagerError?, _ data:[String:Any]?, _ callback:@escaping userCallback) {
        print(error ?? "")
        print(data ?? "")
        // callback(error?.specificCode, nil)
        UserManager.get(callback)
    }
    
    func saveUser(user:User, phone:[String:Any]?, address:[String:Any]?, imageData: Data?, callback: @escaping userCallback) {
       
        if let imageData = imageData {
            
            var data = [String:Any]()
            data["path"] = "user"
            data["userid"] = user.id
            data["picture"] = imageData
            
            APIManager.Instance.perform(call: .userImageUpload, with: data, completition: { (error, data) in
                if error == nil && data != nil {
                    self.saveUser(user: user, phone: phone, address: address, callback: callback)
                }else{
                    self.handeUser(with: error, data, callback)
                }
            })
            
        }else{
            saveUser(user: user, phone: phone, address: address, callback: callback)
        }
    }
    
    fileprivate func saveUser(user:User, phone:[String:Any]?, address:[String:Any]?, callback: @escaping userCallback){
        APIManager.Instance.perform(call: .setUser, with: UserManager.parse(user, phone, address)) { (error, data) in
            if error == nil && data != nil {
                self.handleUser(with: data, callback)
            }else{
                self.handeUser(with: error, data, callback)
            }
        }
    }
    
    func removeUser() -> Bool {
        if AuthManager.Instance.isAuthenticated() {
            return UserManager.remove()
        }
        return true
    }
    
    // MARK: - Pet
    
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
    
    func setPet(_ data: [String:Any], callback: @escaping petUpsertCallback){
        PetManager.upsertPet(data)
        callback(nil)
    }
    
    func getPetUsers(_ petId: Int, callback: @escaping petUsersCallback){
        
//        APIManager.Instance.perform(call: .getPetUsers) { (error, data) in
//            if error == nil && data != nil {
//                
//            }else{
//                
//            }
//        }
        var users = [_petUser]()
        for i in 1...5 {
            var user = _petUser()
            user.name = "User \(i)"
            user.surname = "Surname"
            user.isOwner = i == 2
            users.append(user)
        }
        callback(nil, users)
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



