//
//  UserManager.swift
//  PawTrails
//
//  Created by Marc Perello on 07/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import RxSwift

class DataManager: NSObject {
    
    static let instance = DataManager()
    
    typealias errorCallback = (_ error:DataManagerError?) -> Void
    typealias userCallback = (_ error:DataManagerError?, _ user:User?) -> Void
    typealias petCheckDeviceCallback = (_ isIdle:Bool) -> Void
    typealias petCallback = (_ error:DataManagerError?, _ pet:Pet?) -> Void
    typealias petsCallback = (_ error:DataManagerError?, _ pets:[Pet]?) -> Void
    typealias petsSplittedCallback = (_ error:DataManagerError?, _ owned:[Pet]?, _ shared:[Pet]?) -> Void
    typealias breedsCallback = ((_ error:DataManagerError?, _ breeds:[Breed]?) -> Void)
    typealias breedCallback = (_ error:DataManagerError?, _ breed:Breed?) -> Void
    typealias petUserCallback = ((_ error:DataManagerError?, _ users:PetUser?) -> Void)
    typealias petUsersCallback = ((_ error:DataManagerError?, _ users:[PetUser]?) -> Void)
    typealias safezonesCallback = ((_ error:DataManagerError?, _ safezones:[SafeZone]?) -> Void)
    typealias safezoneCallback = ((_ error:DataManagerError?, _ safezone:SafeZone?) -> Void)
    typealias startTripCallBack = ((_ error:DataManagerError?, _ safezone:[Trip]?) -> Void)
    
    let disposeBag = DisposeBag()
    var userToken: Variable<String?> = Variable(nil)
    var petsDevicesData: Variable<[PetDeviceData]> = Variable([PetDeviceData]())
    
    override init() {
        super.init()

        // Set authenticated user reactive var
        let token = SharedPreferences.get(.token)
        
        if token.count > 0 {
            self.userToken.value = token
        }
    }
    
    //MARK:- Authentication
    
    /// Checks if user is properly authenticated
    ///
    /// - Returns: bool value
    func isAuthenticated() -> Bool {
        return SharedPreferences.has(.id) && SharedPreferences.has(.token)
    }

    
    /// Check is the user is logged by social media
    ///
    /// - Returns: bool value
    func isSocialMedia() -> String? {
        return SharedPreferences.get(.socialnetwork)
    }
    
    /// Attempts to sign up the user to the API, log the user in the system.
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    ///   - callback: *nil* or *error*
    func signUp(_ email:String, _ password: String, callback: @escaping errorCallback) {
        
        APIRepository.instance.signUp(email, password) { (error, authentication) in
            
            if let error = error {
                self.handleAuthErrors(error, authentication, callback: callback)
            }else if let authentication = authentication {
                self.succeedLoginOrRegister(authentication, callback: callback)
            }
        }
    }
    
    /// Attempts to sign in the user to the API, log the user in the system.
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    ///   - callback: *nil* or *error*
    func signIn(_ email:String, _ password: String, callback: @escaping errorCallback) {
        
        APIRepository.instance.signIn(email, password) { (error, authentication) in
            
            if let error = error {
                self.handleAuthErrors(error, authentication, callback: callback)
            }else if let authentication = authentication {
                self.succeedLoginOrRegister(authentication, callback: callback)
            }
        }
    }
    
    /// Attempts to log in the user with Social Media to the API, log the user in the system.
    ///
    /// - Parameters:
    ///   - socialMedia: social media type
    ///   - token: social media token
    ///   - callback: *nil* or *error*
    func login(socialMedia: SocialMedia, _ token: String, callback: @escaping errorCallback){
        APIRepository.instance.login(socialMedia: socialMedia, token) { (error, authentication) in
            
            if let error = error {
                self.handleAuthErrors(error, authentication, callback: callback)
            }else if let authentication = authentication {
                self.succeedLoginOrRegister(authentication, callback: callback)
            }
        }
    }
    
    fileprivate func succeedLoginOrRegister(_ authentication: Authentication, callback: @escaping errorCallback){
        
        guard let token = authentication.token else {
            callback(DataManagerError.init(responseError: ResponseError.NotFound))
            return
        }
        guard let user = authentication.user else {
            callback(DataManagerError.init(responseError: ResponseError.NotFound))
            return
        }
        guard let userId = authentication.user?.id else {
            callback(DataManagerError.init(responseError: ResponseError.NotFound))
            return
        }
        
        // Set authenticated user reactive var
        self.userToken.value = authentication.token
        
        if let socialNetwork = authentication.socialNetwork?.rawValue {
            SharedPreferences.set(.socialnetwork, with: socialNetwork)
        }
        SharedPreferences.set(.token, with: token)
        SharedPreferences.set(.id, with: "\(userId)")
        Reporter.setUser(name: user.name, email: user.email, id: user.id.toString)
        
        var errors = [DataManagerError]()
        let queue = DispatchQueue(label: "ErrorQueue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        let tasks = DispatchGroup()
        
        tasks.enter()
        DataManager.instance.set(user) { (error, user) in

            if let error = error {
                queue.async {
                    errors.append(error)
                }
            }
            tasks.leave()
        }
        
        tasks.enter()
        DataManager.instance.loadPets(callback: { (error, pets) in
            if let error = error {
                queue.async {
                    errors.append(error)
                }
            }
            tasks.leave()
        })
        
        DataManager.instance.getCountryCodes { (_) in }
        
        tasks.notify(queue: .main) {
            
            queue.sync {
                for error in errors { Reporter.send(file: "\(#file)", function: "\(#function)", error) }
            }
            callback(nil)
        }
        SocketIOManager.instance.reconnect()
    }
    
    /// Removes user from this client as well as wipes out all the information related to the user.
    ///
    /// - Returns: bool value to verify the operation was complete successfully.
    func signOut() -> Bool {
//        CoreDataManager.instance.deleteAll()
        APIRepository.instance.logout { (error) in
            if error == nil {
                print("Logged out successfuly")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        let response = SharedPreferences.remove(.id) && SharedPreferences.remove(.token)
        let _ = SharedPreferences.remove(.socialnetwork)
        SocketIOManager.instance.disconnect()
        return response
    }
    
    /// Sends password reset request to API
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - callback: *nil* or *error*
    func sendPasswordReset(_ email:String, callback: @escaping errorCallback) {
        
        APIRepository.instance.sendPasswordReset(email) { (error) in
            if let error = error {
                self.handleAuthErrors(error, callback: callback)
            }else{
                callback(nil)
            }
        }
    }
    
    /// Attempts to change user password
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user current password
    ///   - newPassword: user new password
    ///   - callback: *nil* or *error*
    func changeUsersPassword(_ email:String, _ password:String, _ newPassword:String, callback: @escaping errorCallback) {
        
        let id = Int(SharedPreferences.get(.id)) ?? 0
        
        APIRepository.instance.changeUsersPassword(id, email, password, newPassword) { (error) in
            if let error = error {
                self.handleAuthErrors(error, callback: callback)
            }else{
                callback(nil)
            }
        }
    }
    
    /// Attempts to change user notification value
    ///
    /// - Parameters:
    ///   - status: bool value
    ///   - callback: *nil* or *error*
    func saveUserNotification(_ status:Bool, callback: @escaping errorCallback) {
        
        let id = Int(SharedPreferences.get(.id)) ?? 0
        
        APIRepository.instance.saveUserNotification(status, by: id) { (error) in
            if let error = error {
                callback(DataManagerError.init(APIError: error))
            }else{
                callback(nil)
            }
        }
    }
    
    fileprivate func handleAuthErrors(_ error: APIManagerError, _ authentication: Authentication? = nil, callback: @escaping errorCallback) {
        callback(DataManagerError(APIError: error))
    }
    
    // MARK: - User
    
    /// Update user in local storage
    ///
    /// - Parameters:
    ///   - user: user
    ///   - callback: returns stored user or *error*
    func set(_ user: User, callback: @escaping userCallback){
        
        CDRepository.instance.upsert(user) { (error, user) in
            if error == nil, let user = user {
                callback(nil, user)
            }else if let error = error {
                callback(DataManagerError(DBError: error), nil)
            }
        }
    }
    

    /// Get user from local storage
    ///
    /// - Parameter callback: return stored user or *error*
    func getUser(callback:@escaping userCallback){
        
        let id = Int(SharedPreferences.get(.id)) ?? 0
        
        CDRepository.instance.getUser(by: id) { (error, user) in
            if error == nil, let user = user {
                callback(nil, user)
            }else if let error = error {
                callback(DataManagerError(DBError: error), nil)
            }
        }
    }
    
    /// Collect user from API and update it on local storage
    ///
    /// - Parameter callback: return stored user or *error*
    func loadUser(callback:@escaping userCallback) {
        
        let id = Int(SharedPreferences.get(.id)) ?? 0
        
        APIRepository.instance.loadUser(by: id) { (error, user) in
            self.handle(error, user, callback: callback)
        }
    }
    
    
    /// Upload user image to API and update it on the local storage
    ///
    /// - Parameters:
    ///   - image: image data
    ///   - callback: return *nil* or *error*
    func saveUser(image: Data, callback: @escaping errorCallback){
        
        let id = Int(SharedPreferences.get(.id)) ?? 0
        
        APIRepository.instance.saveUser(image, by: id) { (error) in
            if let error = error {
                callback(DataManagerError.init(APIError: error))
            }else{
                callback(nil)
            }
        }
    }
    
    /// Update user to API and local storage
    ///
    /// - Parameters:
    ///   - user: user
    ///   - callback: return stored user or *error*
    func save(_ user: User, callback: @escaping userCallback) {
        
        APIRepository.instance.save(user) { (error, user) in
            self.handle(error, user, callback: callback)
        }
    }
    
    private func handle(_ error:APIManagerError?,_ user: User?, callback: @escaping userCallback) {
        if error == nil, let user = user {
            self.set(user, callback: callback)
        }else if let error = error {
            callback(DataManagerError(APIError: error), nil)
        }
    }
    
    /// Remove user from local storage
    ///
    /// - Parameter callback: bool value
    func removeUser(callback: @escaping (Bool)->Void) {
        let id = Int(SharedPreferences.get(.id)) ?? 0
        if isAuthenticated() {
            CDRepository.instance.removeUser(by: id, callback: callback)
        }else{
            callback(false)
        }
    }
    
    // MARK: - Pet
    
    /// Update pet in local storage
    ///
    /// - Parameters:
    ///   - pet: pet
    ///   - callback: returns stored pet or *error*
    func set(_ pet: Pet, callback: petCallback? = nil) {
        
        CDRepository.instance.upsert(pet) { (error, pet) in
            if error == nil, let pet = pet, let callback = callback {
//                SocketIOManager.instance.startGPSUpdates(for: [pet.id])
                callback(nil, pet)
            }else if let error = error, let callback = callback{
                callback(DataManagerError(DBError: error), nil)
            }
        }
    }
    
    /// Get pet from local storage
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: stored pet or *error*
    func getPet(by petId:Int, callback: @escaping petCallback) {
        CDRepository.instance.getPet(by: petId) { (error, pet) in
            if error == nil, let pet = pet{
                callback(nil, pet)
            }else if let error = error {
                callback(DataManagerError(DBError: error), nil)
            }

        }
    }
    
    /// Remove pet from local storage
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func removePetDB(by petId: Int, callback: @escaping errorCallback) {
        
        CDRepository.instance.removePet(by: petId) { (success) in
//            SocketIOManager.instance.stopGPSUpdates(for: petId)
            callback(success ? nil : DataManagerError(DBError: DatabaseError(type: .Unknown, entity: Entity.pet, action: .remove, error: nil)))
        }
    }
    
    /// Check device code with API
    ///
    /// - Parameters:
    ///   - deviceCode: deviceCode
    ///   - callback: bool value
    func check(_ deviceCode: String, callback: @escaping petCheckDeviceCallback) {
        APIRepository.instance.check(deviceCode) { (error, isCodeValid) in
            if let error = error {
                Reporter.send(file: "\(#file)", function: "\(#function)", error)
            }
            callback(error == nil && isCodeValid)
        }
    }
    
    /// Change Device Code
    ///
    /// - Parameters:
    ///   - deviceCode: deviceCode
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func change(_ deviceCode: String, of petId:Int, callback: @escaping errorCallback){
        
        APIRepository.instance.change(deviceCode, of: petId) { (error) in
            if let error = error {
                callback(DataManagerError(APIError: error))
            }else{
                callback(nil)
            }
        }
    }
    

    
    
    
    /// Register pet in API and local storage
    ///
    /// - Parameters:
    ///   - pet: pet to register
    ///   - callback: registered pet
    func register(_ pet: Pet, callback: @escaping petCallback) {
        
        APIRepository.instance.register(pet: pet) { (error, pet) in

            if error == nil, let pet = pet {
                self.set(pet, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }
        }
    }
    
    
    
    
    
    
    /// Get pet from API and update local storage
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: pet information or *error*
    func loadPet(_ petId:Int, callback: @escaping petCallback) {
        
        APIRepository.instance.loadPet(petId) { (error, pet) in

            if error == nil, let pet = pet {
                self.set(pet, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }
        }
    }
    
    /// Remove pet API and local storage
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func removePet(_ petId: Int, callback: @escaping errorCallback) {
        APIRepository.instance.removePet(petId) { (error) in
            if error == nil {
                self.removePetDB(by: petId, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    /// Get pet list from local storage
    ///
    /// - Parameter callback: pets or *error*
    func getPets(callback: @escaping petsCallback) {
        
        CDRepository.instance.getPets { (error, pets) in
            if error == nil, let pets = pets {
                callback(nil, pets)
            }else if let error = error {
                callback(DataManagerError.init(DBError: error), nil)
            }
        }
    }
    
    /// Get pet list splitted (shared/owned) from local storage
    ///
    /// - Parameter callback: shared/owned or *error*
    func getPetsSplitted(callback: @escaping petsSplittedCallback) {
        
        getPets { (error, pets) in
            if error == nil, let pets = pets {
                let owned = pets.filter({ $0.isOwner == true })
                let shared = pets.filter({ $0.isOwner == false })
                callback(error, owned, shared)
            }else if let error = error {
                callback(error, nil, nil)
            }
        }
    }
    
    /// Get pets from API and update local storage. (In addition, it checks for missing breeds, and download them if empty)
    ///
    /// - Parameter callback: pets or *error*
    func loadPets(callback: @escaping petsCallback) {
        
        checkBreeds { (_) in
            
            APIRepository.instance.loadPets { (error, pets) in
                
                if error == nil, let pets = pets {
                    
                    CDRepository.instance.upsert(pets, callback: { (error, pets) in
                        if error == nil, let pets = pets {
                            callback(nil, pets)
                        }else if let error = error {
                            callback(DataManagerError(DBError: error), nil)
                        }
                    })
                    
                }else if let error = error {
                    callback(DataManagerError(APIError: error), nil)
                }
            }
        }
        
    }
    
    

    /// Update pet to API and local storage
    ///
    /// - Parameters:
    ///   - pet: pet
    ///   - callback: nil or *error*
    func save(_ pet: Pet, callback: @escaping errorCallback){
        
        APIRepository.instance.save(pet) { (error, pet) in

            if error == nil, let pet = pet {
                self.set(pet, callback: { (error, pet) in
                    if error == nil && pet != nil {
                        callback(nil)
                    }else if let error = error {
                        callback(error)
                    }else{
                        callback(DataManagerError(DBError: DatabaseError(type: .Unknown, entity: Entity.pet, action: .save, error: nil)))
                    }
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    /// Upload pet image to API and update it on the local storage
    ///
    /// - Parameters:
    ///   - image: image data
    ///   - id: pet id
    ///   - callback: return *nil* or *error*
    func savePet(image: Data, into id: Int, callback: @escaping errorCallback){
        
        APIRepository.instance.savePet(image, by: id) { (error) in

            if let error = error {
                callback(DataManagerError.init(APIError: error))
            }else{
                callback(nil)
            }
        }
    }
    
    // MARK: - Pet Breeds
    
    /// Check Local Breeds and download them if need
    ///
    /// -  callback: error list, it might be empty if no errors
    func checkBreeds(callback: @escaping ([DataManagerError])->Void) {
        
        var errors = [DataManagerError]()
        let queue = DispatchQueue(label: "ErrorQueueBreeds", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)

        let group = DispatchGroup()
        
        for type in [Type.cat, Type.dog] {
            
            getBreeds(for: type) { (error, breeds) in
                if breeds == nil {
                    group.enter()
                    self.loadBreeds(for: type, callback: { (error, breeds) in
                        if let error = error {
                            queue.sync {
                                errors.append(error)
                            }
                        }
                        group.leave()
                    })
                }
            }
        }
        
        group.notify(queue: .main) {
            for error in errors {
                Reporter.send(file: "\(#file)", function: "\(#function)", error)
            }
            callback(errors)
        }
        
    }
    
    /// Get local breeds
    ///
    /// - Parameters:
    ///   - type: type of pet
    ///   - callback: breeds
    func getBreeds(for type: Type, callback: @escaping breedsCallback) {

        CDRepository.instance.getBreeds(for: type) { (error, breeds) in
            if let error = error {
                callback(DataManagerError.init(DBError: error), nil)
            }else{
                callback(nil, breeds)
            }
        }
    }
    
    /// Get breeds from API and update local storage
    ///
    /// - Parameters:
    ///   - type: type of pet
    ///   - callback: stored breeds
    func loadBreeds(for type: Type, callback: @escaping breedsCallback) {
        
        if type == .cat || type == .dog {
            
            APIRepository.instance.loadBreeds(for: type, callback: { (error, breeds) in

                if error == nil, let breeds = breeds {
                    
                    CDRepository.instance.upsert(breeds, for: type, callback: { (success) in
                        if success {
                            callback(nil, breeds)
                        }else{
                            callback(DataManagerError(DBError: DatabaseError(type: .Unknown, entity: Entity.breed, action: .upsert, error: nil)), nil)
                        }
                    })

                }else if let error = error {
                    callback(DataManagerError(APIError: error), nil)
                }
            })
        }else {
            callback(DataManagerError.init(responseError: ResponseError.NotFound), nil)
        }
    }
    
    // MARK: - Pet Sharing
    
    /// Get user pet friends from API and update local storage
    ///
    /// - Parameter callback: friends or *error*
    func loadPetFriends(callback: @escaping petUsersCallback){
        
        APIRepository.instance.loadPetFriends { (error, friends) in

            if error == nil, let friends = friends {

                let id = Int(SharedPreferences.get(.id)) ?? 0
                
                CDRepository.instance.upsertUser(friends, into: id, callback: { (error, friends) in
                    if error == nil, let friends = friends {
                        callback(nil, friends)
                    }else if let error = error {
                        callback(DataManagerError(DBError: error), nil)
                    }
                })
                
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }else {
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "DataManager - Load Pet Friends", error ?? "nil error", friends ?? "nil friends")
                callback(nil, nil)
            }
        }
    }
    
    /// Get local new pet friends for specific pet
    ///
    /// - Parameters:
    ///   - pet: pet
    ///   - callback: new friends or *error*
    func getPetFriends(for pet: Pet, callback: @escaping petUsersCallback){
        
        let id = Int(SharedPreferences.get(.id)) ?? 0
        
        CDRepository.instance.getUserFriends(by: id) { (error, friends) in

            if let error = error {
                callback(DataManagerError(DBError: error), nil)
            }else if let friends = friends, let petUsers = pet.users {
                let feaseableNewUsers = friends.filter({ !petUsers.contains($0) })
                callback(nil, feaseableNewUsers)
            }
        }
    }
    
    /// Get shared pet users from API and update local storage
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: shared users or *error*
    func loadSharedPetUsers(for petId: Int, callback: petUsersCallback?) {
        
        APIRepository.instance.loadSharedPetUsers(for: petId) { (error, users) in

            if error == nil, let users = users {

                CDRepository.instance.upsert(users, into: petId, callback: { (error, users) in
                    if error == nil, let users = users, let callback = callback {
                        callback(nil, users)
                    }else if let error = error,  let callback = callback {
                        callback(DataManagerError.init(DBError: error), nil)
                    }
                })
                
            }else if let error = error, let callback = callback {
                callback(DataManagerError(APIError: error), nil)
            }else {
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "DataManager - Load Share Pet Users", error ?? "nil error", users ?? "nil users")
                if let callback = callback { callback(nil, nil) }
            }
        }
    }
    
       
    
    /// Add new shared user to pet to API and update local storage
    ///
    /// - Parameters:
    ///   - email: email
    ///   - petId: pet id
    ///   - callback: new shared petuser or *error*
    func addSharedUser( by email: String, to petId: Int, callback: @escaping petUserCallback) {
        
        APIRepository.instance.addSharedUser( by: email, to: petId) { (error, petuser) in

            if error == nil, let petuser = petuser {
                self.addDB(petuser, to: petId, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }
        }
    }
    
    /// Add Shared User to local storage
    ///
    /// - Parameters:
    ///   - sharedUser: new shared user to add
    ///   - petId: pet id
    ///   - callback: shared user added or *error*
    func addDB(_ sharedUser: PetUser, to petId: Int, callback: @escaping petUserCallback){

        CDRepository.instance.upsert(sharedUser, into: petId) { (error, user) in
        
            if error == nil, let user = user {
                callback(nil, user)
            }else if let error = error {
                callback(DataManagerError(DBError: error), nil)
            }
        }
    }
    
    /// Remove Shared User to API and Update local storage
    ///
    /// - Parameters:
    ///   - id: shared user id
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func removeSharedUser(by id:Int, from petId: Int, callback: @escaping errorCallback) {
        
        APIRepository.instance.removeSharedUser(by:id, from: petId) { (error) in
            if error == nil {
                self.removeSharedUserDB(id: id, from: petId, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    /// Remove Shared User from local Storage
    ///
    /// - Parameters:
    ///   - id: shared user id
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func removeSharedUserDB(id: Int, from petId:Int, callback: @escaping errorCallback){

        CDRepository.instance.removeSharedPetUser(with: id, from: petId) { (error) in
        
            if let error = error {
                callback(DataManagerError(DBError: error))
            }else{
                callback(nil)
            }
        }
    }
    
    /// Leave Shared Pet
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func leaveSharedPet(by petId: Int, callback: @escaping errorCallback) {
        
        APIRepository.instance.leaveSharedPet(by: petId) { (error) in
            if error == nil {
                self.removePetDB(by: petId, callback: callback)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    // MARK: - Pet Safe Zones
    
    /// Get pet Safe Zones from API and update local storage.
    ///
    /// - Parameters:
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func loadSafeZones(of petId:Int, callback: @escaping errorCallback) {
        APIRepository.instance.loadSafeZones(of: petId) { (error, safezones) in
            if error == nil, let safezones = safezones {
                CDRepository.instance.upsert(safezones, into: petId)
                callback(nil)
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    /// Add SafeZone to API and update local storage
    ///
    /// - Parameters:
    ///   - safezone: safezone to add
    ///   - petId: pet id
    ///   - callback: safezone added or *error*
    func add(_ safezone: SafeZone, to petId: Int, callback: @escaping safezoneCallback) {
        APIRepository.instance.add(safezone, to: petId) { (error, safezone) in
            if error == nil, let safezone = safezone {
                CDRepository.instance.upsert(safezone, into: petId, callback: { (error, safezones) in
                    if error == nil, safezones != nil {
                        callback(nil, safezone)
                    }else if let error = error {
                        callback(DataManagerError.init(DBError: error), nil)
                    }
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error), nil)
            }
        }
    }
    
    /// Update SafeZone to API and update local storage
    ///
    /// - Parameters:
    ///   - safezone: safezone to update
    ///   - petId: pet id
    ///   - callback: updated safe zone or *error*
    func save(_ safezone: SafeZone, into petId: Int, callback: @escaping errorCallback) {
        APIRepository.instance.save(safezone, to: petId) { (error) in
            if error == nil {
                // CHECK
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    /// Update SafeZone Status to API and update local storage.
    ///
    /// - Parameters:
    ///   - status: enabled/disabled
    ///   - id: safezone id
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func setSafeZoneStatus(status: Bool,for id: Int, into petId: Int, callback: @escaping errorCallback) {
        
        APIRepository.instance.setSafeZone(status: status, for: id, into: petId) { (error) in

            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    /// Remove safezone to API and update local storage.
    ///
    /// - Parameters:
    ///   - safezoneId: safezone id
    ///   - petId: pet id
    ///   - callback: nil or *error*
    func removeSafeZone(by safezoneId: Int, to petId: Int, callback: @escaping errorCallback) {
        
        APIRepository.instance.removeSafeZone(by: safezoneId, to: petId) { (error) in

            if error == nil {
                self.loadSafeZones(of: petId, callback: { (error) in
                    callback(error)
                })
            }else if let error = error {
                callback(DataManagerError(APIError: error))
            }
        }
    }
    
    /// Update SafeZone Image to API and update local storage.
    ///
    /// - Parameters:
    ///   - imageData: image
    ///   - id: safezone id
    ///   - callback: nil or *error*
    func setSafeZone(imageData:Data, for id: Int, callback: @escaping errorCallback){
        CDRepository.instance.setSafeZone(imageData: imageData, for: id) { (error) in
            if let error = error {
                callback(DataManagerError(DBError: error))
            }else{
                callback(nil)
            }
        }
    }

    /// Update SafeZone Address to API and update local storage.
    ///
    /// - Parameters:
    ///   - address: address
    ///   - id: safezone id
    ///   - callback: nil or *error*
    func setSafeZone(address:String, for id: Int, callback: @escaping errorCallback){

        CDRepository.instance.setSafeZone(address: address, for: id) { (error) in
            if let error = error {
                callback(DataManagerError(DBError: error))
            }else{
                callback(nil)
            }
        }
    }
    
    // MARK: - Country Codes
    
    /// Get country codes from local storage
    ///
    /// - Parameter callback: country codes or nil
    func getCountryCodes(callback: @escaping ([CountryCode]?)->Void) {
        CDRepository.instance.getAllCountryCodes(callback: callback)
    }
    
    /// Get Current country code from system
    ///
    /// - Returns: Current country code, if not found return Ireland, IE
    func getCurrentCountryShortName() -> String {
        return Locale.current.regionCode ?? "IE"
    }

    

    
    
    // MARK -- Start Trip and recieve data from api.
    func startMyAdventure(_ petIdss: [Int], callback: @escaping startTripCallBack) {
        APIRepository.instance.startTrips(petIdss) { (error, data) in
            if error == nil {
                callback(nil, data)
            } else if let error = error{
                callback(DataManagerError(APIError: error), nil)
            }
        }
    }

}



