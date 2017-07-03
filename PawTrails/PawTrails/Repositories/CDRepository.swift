//
//  CDRepository.swift
//  PawTrails
//
//  Created by Marc Perello on 26/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class CDRepository {
    
    static let instance = CDRepository()
    
    typealias CDRepErrorCallback = (DatabaseError?) -> Void
    typealias CDRepUserCallback = (DatabaseError?, User?) -> Void
    typealias CDRepPetCallback = (DatabaseError?, Pet?) -> Void
    typealias CDRepPetsCallback = (DatabaseError?, [Pet]?) -> Void
    typealias CDRepPetUserCallback = (DatabaseError?, PetUser?) -> Void
    typealias CDRepPetUsersCallback = (DatabaseError?, [PetUser]?) -> Void
    typealias CDRepSafeZoneCallback = (DatabaseError?, SafeZone?) -> Void
    typealias CDRepSafeZonesCallback = (DatabaseError?, [SafeZone]?) -> Void
    typealias CDRepBreedCallback = (DatabaseError?, Breed?) -> Void
    typealias CDRepBreedsCallback = (DatabaseError?, [Breed]?) -> Void
        
    //MARK:- User
    
    func upsert(_ user: User, callback: @escaping CDRepUserCallback) {
        
        CoreDataManager.instance.upsert(.user, with: ["id":user.id]) { (object) in
            
            if let cdUser = object as? CDUser {
                
                cdUser.name = user.name
                cdUser.surname = user.surname
                cdUser.email = user.email
                cdUser.notification = user.notification
                cdUser.birthday = user.birthday
                cdUser.gender = user.gender?.rawValue ?? Int16(-1.0)
                
                let group = DispatchGroup()
                
                // Address
                
                if let address = user.address {
                    
                    if cdUser.address == nil { // Create
                        group.enter()
                        CoreDataManager.instance.store(.address, with: ["city":""], callback: { (object) in
                            if let cdAddress = object as? CDAddress {
                                cdUser.address = cdAddress
                                cdUser.address?.city = address.city
                                cdUser.address?.country = address.country
                                cdUser.address?.line0 = address.line0
                                cdUser.address?.line1 = address.line1
                                cdUser.address?.line2 = address.line2
                                cdUser.address?.postal_code = address.postalCode
                                cdUser.address?.state = address.state
                            }
                            group.leave()
                        })
                    } else{
                        cdUser.address?.city = address.city
                        cdUser.address?.country = address.country
                        cdUser.address?.line0 = address.line0
                        cdUser.address?.line1 = address.line1
                        cdUser.address?.line2 = address.line2
                        cdUser.address?.postal_code = address.postalCode
                        cdUser.address?.state = address.state
                    }
                    
                }else{ //Remove
                    cdUser.setValue(nil, forKey: "address")
                }
                
                // Phone
                
                if let phone = user.phone {
                    if cdUser.phone == nil { // Create
                        group.enter()
                        CoreDataManager.instance.store(.phone, with: ["number":""], callback: { (object) in
                            if let cdPhone = object as? CDPhone {
                                cdUser.phone = cdPhone
                                cdUser.phone?.number = phone.number
                                cdUser.phone?.country_code = phone.countryCode
                            }
                            group.leave()
                        })
                    } else{
                        cdUser.phone?.number = phone.number
                        cdUser.phone?.country_code = phone.countryCode
                    }
                    
                }else{ //Remove
                    cdUser.setValue(nil, forKey: "phone")
                }
                
                // Image
                
                if let imageURL = user.imageURL {
                    
                    if cdUser.imageURL == nil || (cdUser.imageURL != nil && cdUser.imageURL != imageURL) {
                        cdUser.imageURL = imageURL
                        cdUser.image = Data.build(with: imageURL)
                    }
                }
                
                group.notify(queue: .main, execute: { 
                    CoreDataManager.instance.save(callback: { (error) in
                        if let error = error {
                            callback(error, nil)
                        } else {
                            callback(nil, User(cdUser))
                        }
                    })
                })
            }
        }
    }
    
    private func getUserCD(by id: Int, _ callback: @escaping (DatabaseError?, CDUser?)->Void ) {
        
        CoreDataManager.instance.retrieve(.user, with: NSPredicate("id", .equal, id)) { (objects) in
            if let results = objects as? [CDUser] {
                if results.count > 1 {
                    
                    callback(DatabaseError(type: .DuplicatedEntry, entity: Entity.user, action: .get, error: nil), nil)
                }else{
                    callback(nil, results.first!)
                }
            }else{
                callback(DatabaseError(type: .NotFound, entity: Entity.user, action: .get, error: nil), nil)
            }
        }
    }
    
    func getUser(by id: Int, _ callback: @escaping CDRepUserCallback) {
        
        getUserCD(by: id) { (error, cdUser) in
            if let cdUser = cdUser {
                callback(error, User(cdUser))
            }else{
                callback(error, nil)
            }
        }
    }
    
    func removeUser(by id: Int, callback: @escaping (Bool)->Void) {
        let predicate = NSPredicate("id", .equal, id)
        CoreDataManager.instance.delete(entity: .user, withPredicate: predicate)
        CoreDataManager.instance.retrieve(.user, with: predicate) { (objects) in
            callback(objects == nil)
        }
    }
    
    //MARK:- Pet
    
    func upsert(_ pet: Pet, callback: @escaping CDRepPetCallback) {
        
        CoreDataManager.instance.upsert(.pet, with: ["id":pet.id]) { (object) in
            
            if let cdPet = object as? CDPet {
                
                cdPet.name = pet.name
                cdPet.weight = pet.weight ?? 0.0
                cdPet.neutered = pet.neutered
                cdPet.birthday = pet.birthday
                cdPet.isOwner =  pet.isOwner
                cdPet.type = pet.type?.type?.rawValue ?? Int16(-1.0)
                cdPet.gender = pet.gender?.rawValue ?? Int16(-1.0)
               
                let group = DispatchGroup()
                
                // Breeds
                if let type = Type(rawValue: cdPet.type) {
                    
                    // First Breed
                    if let firstBreedId = pet.breeds?.breeds[0] {
                        group.enter()
                        self.getBreedDB(for: type, breedId: firstBreedId, callback: { (error, breed) in
                            if error == nil { cdPet.firstBreed = breed }
                            group.leave()
                        })
                    }else{
                        cdPet.setValue(nil, forKey: "firstBreed")
                    }
                    
                    // Second Breed
                    if let secondBreedId = pet.breeds?.breeds[1] {
                        group.enter()
                        self.getBreedDB(for: type, breedId: secondBreedId, callback: { (error, breed) in
                            if error == nil { cdPet.secondBreed = breed }
                            group.leave()
                        })
                    }else{
                        cdPet.setValue(nil, forKey: "secondBreed")
                    }
                }
                cdPet.type_descr = pet.type?.description
                cdPet.breed_descr = pet.breeds?.description
                
                // Image
                if let imageURL = pet.imageURL {
                    
                    if cdPet.imageURL == nil || (cdPet.imageURL != nil && cdPet.imageURL != imageURL) {
                        cdPet.imageURL = imageURL
                        cdPet.image = Data.build(with: imageURL)
                    }
                }
                group.notify(queue: .main, execute: { 
                    CoreDataManager.instance.save(callback: { (error) in
                        if let error = error {
                            callback(error, nil)
                        } else {
                            callback(nil, Pet(cdPet))
                        }
                    })
                })
                
            }
        }
    }
    
    func upsert(_ pets: [Pet], callback: @escaping CDRepPetsCallback) {
       
        var updatedPets = [Pet]()
        var errors = [DatabaseError]()
        let group = DispatchGroup()
        
        self.getPets { (error, localpets) in
            
            if error == nil, let localpets = localpets {
                var localpetIDs = localpets.map({ $0.id })

                //Update
                for pet in pets {
                    if let index = localpetIDs.index(of: pet.id) {
                        localpetIDs.remove(at: index)
                    }
                    group.enter()
                    self.upsert(pet, callback: { (error, pet) in
                        if error == nil, let pet = pet {
                            updatedPets.append(pet)
                        }else if let error = error {
                            errors.append(error)
                        }
                        group.leave()
                    })
                }
                //Remove
                for id in localpetIDs {
                    group.enter()
                    self.removePet(by: id, callback: { (success) in
                        if !success {
                            errors.append(DatabaseError(type: .Unknown, entity: Entity.pet, action: .remove, error: nil))
                        }
                        group.leave()
                    })
                }
            }else{
                for pet in pets {
                    group.enter()
                    self.upsert(pet, callback: { (error, pet) in
                        if error == nil, let pet = pet {
                            updatedPets.append(pet)
                        }else if let error = error {
                            errors.append(error)
                        }
                        group.leave()
                    })
                }
            }
            
            group.notify(queue: .main, execute: { 
                if errors.count == 0 {
                    callback(nil,updatedPets)
                }else{
                    debugPrint("Upsert Pet List Errors", errors)
                    callback(errors.first, nil)
                }
            })
        }
    }
    
    func savePet(_ deviceCode: String, _ id: Int, _ callback: @escaping CDRepErrorCallback){
        
        getPetCD(by: id) { (error, pet) in
            if let pet = pet {
                pet.deviceCode = deviceCode
                CoreDataManager.instance.save(callback: { (error) in
                    if let error = error {
                        callback(error)
                    }else{
                        callback(nil)
                    }
                })
            }else if let error = error {
                callback(error)
            }
        }
    }
    
    private func getPetCD(by id:Int, _ callback: @escaping (DatabaseError?, CDPet?)-> Void) {
        
        CoreDataManager.instance.retrieve(.pet, with: NSPredicate("id", .equal, id)) { (objects) in
            if let results = objects as? [CDPet] {
                if results.count > 1 {
                    
                    callback(DatabaseError(type: .DuplicatedEntry, entity: Entity.pet, action: .get, error: nil), nil)
                }else{
                    callback(nil, results.first!)
                }
            }else{
                callback(DatabaseError(type: .NotFound, entity: Entity.pet, action: .get, error: nil), nil)
            }
        }
    }
    
    func getPet(by id:Int, _ callback: @escaping CDRepPetCallback) {
        
        self.getPetCD(by: id) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                callback(nil, Pet(cdPet))
            }else{
                callback(error, nil)
            }
        }
    }
    
    func getPets(callback: @escaping CDRepPetsCallback) {
        
        CoreDataManager.instance.retrieve(.pet, sortedBy: [NSSortDescriptor(key: "name", ascending: true)]) { (objects) in
            callback(nil, (objects as? [CDPet])?.map({ Pet($0) }))
        }
    }
    
    func removePet(by id: Int, callback: @escaping (Bool)->Void) {
        let predicate = NSPredicate("id", .equal, id)
        CoreDataManager.instance.delete(entity: .pet, withPredicate: predicate)
        CoreDataManager.instance.retrieve(.pet, with: predicate) { (object) in
            callback(object == nil)
        }
    }
    
    //MARK:- PetUser
    
    private func upsert(_ petUser: PetUser, callback: @escaping (CDPetUser?)->Void) {
        
        CoreDataManager.instance.upsert(.petUser, with: ["id":petUser.id]) { (object) in
            
            if let user = object as? CDPetUser {
                
                user.name = petUser.name
                user.surname = petUser.surname
                user.email = petUser.email
                user.isOwner = petUser.isOwner
                
                if let imageURL = petUser.imageURL {
                    
                    if user.imageURL == nil || (user.imageURL != nil && user.imageURL != imageURL) {
                        user.imageURL = imageURL
                        user.image = Data.build(with: imageURL)
                    }
                }
                callback(user)
            }else{
                callback(nil)
            }
        }
    }
    
    func upsert(_ petUser: PetUser, into petId: Int, callback: CDRepPetUserCallback? = nil){
        
        
        getPetCD(by: petId) { (error, cdPet) in
            
            if error == nil, let cdPet = cdPet {
                
                let users = cdPet.mutableSetValue(forKey: "users")
                
                self.upsert(petUser, callback: { (cdPetUser) in
                    
                    if let cdPetUser = cdPetUser {
                        
                        if (users.allObjects as? [CDPetUser])?.first(where: { $0.id == cdPetUser.id }) == nil {
                            users.add(cdPetUser)
                        }
                        
                        cdPet.setValue(users, forKey: "users")
                        
                        CoreDataManager.instance.save(callback: { (error) in
                            if let error = error, let callback = callback {
                                callback(error, nil)
                            } else if let callback = callback{
                                callback(nil, PetUser(cdPetUser))
                            }
                        })
                        
                    }else if let callback = callback {
                        callback(DatabaseError(type: .NotFound, entity: Entity.pet, action: .upsert, error: nil), nil)
                        return
                    }
                })
            }else if let error = error, let callback = callback {
                callback(error, nil)
            }else if let callback = callback {
                debugPrint(error ?? "error nil", cdPet ?? "pet nil")
                callback(nil, nil)
            }
        }
    }
    
    func upsert(_ petUsers:[PetUser], into petId: Int, callback: CDRepPetUsersCallback? = nil){
        
        getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                let users = cdPet.mutableSetValue(forKey: "users")
                users.removeAllObjects()
                let group = DispatchGroup()
                for petUser in petUsers {
                    group.enter()
                    self.upsert(petUser, callback: { (cdPetUser) in
                        if let cdPetUser = cdPetUser { users.add(cdPetUser) }
                        group.leave()
                    })
                }
                group.notify(queue: .main, execute: { 
                    cdPet.setValue(users, forKey: "users")
                    CoreDataManager.instance.save(callback: { (error) in
                        if let error = error, let callback = callback {
                            callback(error, nil)
                        } else if let callback = callback{
                            callback(nil, (users.allObjects as? [CDPetUser])?.map({ PetUser($0) }))
                        }
                    })

                })
            }else if let error = error, let callback = callback {
                callback(error, nil)
            }else if let callback = callback {
                debugPrint(error ?? "error nil", cdPet ?? "pet nil")
                callback(nil, nil)
            }
        }
    }
    
    func getPetUsers(by petId:Int, callback: @escaping CDRepPetUsersCallback){
        
        getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPetUsers = cdPet?.users?.allObjects as? [CDPetUser] {
                callback(nil, cdPetUsers.map({ PetUser($0) }))
            }else if let error = error {
                callback(error, nil)
            }else{
                debugPrint(error ?? "error nil", cdPet ?? "pet nil")
                callback(nil, nil)
            }
        }
    }
    
    func removeSharedPetUser(with id: Int, from petId: Int, callback: @escaping CDRepErrorCallback){
        
        getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                if let user = (cdPet.users?.allObjects as? [CDPetUser])?.first(where: { $0.id == id.toInt16 }) {
                    
                    user.removeFromPetUsers(cdPet)
                    CoreDataManager.instance.save(callback: { (error) in
                        if let error = error {
                            callback(error)
                        } else {
                            callback(nil)
                        }
                    })
                    callback(nil)
                    
                }else{
                    callback(DatabaseError(type: .NotFound, entity: Entity.petUser, action: .get, error: nil))
                }
                
            }else if let error = error {
                callback(error)
            }else {
                debugPrint(error ?? "error nil", cdPet ?? "pet nil")
                callback(DatabaseError(type: .Unknown, entity: Entity.pet, action: .get, error: nil))
            }
        }
        
    }
    
    func upsertUser(_ friends: [PetUser], into id: Int, callback: CDRepPetUsersCallback? = nil){
        
        getUserCD(by: id) { (error, cdUser) in
            
            if let cdUser = cdUser {
                let cdFriends = cdUser.mutableSetValue(forKey: "friends")
                cdFriends.removeAllObjects()
                
                let group = DispatchGroup()
                
                for friend in friends {
                    group.enter()
                    self.upsert(friend, callback: { (cdPetUser) in
                        if let petUser = cdPetUser {
                            if petUser.email != nil {
                                cdFriends.add(petUser)
                            }
                        }
                        group.leave()
                    })
                }
                group.notify(queue: .main, execute: { 
                    cdUser.setValue(cdFriends, forKey: "friends")
                    CoreDataManager.instance.save(callback: { (error) in
                        if let error = error, let callback = callback {
                            callback(error, nil)
                        } else if let callback = callback {
                            if let cdFriends = cdFriends.allObjects as? [CDPetUser] {
                                callback(nil, cdFriends.map({ PetUser($0) }))
                            }
                            callback(nil, nil)
                        }
                    })

                })
            }else{
                if let callback = callback { callback(error, nil) }
            }
        }
    }
    
    func getUserFriends(by id: Int, callback: @escaping CDRepPetUsersCallback){
        
        getUser(by: id) { (error, user) in
            if let user = user {
                callback(nil, user.friends)
            }else if let error = error {
                callback(error, nil)
            }else{
                callback(DatabaseError(type: .Unknown, entity: Entity.user, action: .get, error: nil), nil)
            }
        }
    }
    
    //MARK:- SafeZones
    
    private func upsert(_ safezone: SafeZone, callback: @escaping (DatabaseError?, CDSafeZone?)->Void) {
        
        CoreDataManager.instance.upsert(.safeZone,with: ["id":safezone.id]) { (object) in
            
            if let cdSafezone = object as? CDSafeZone {
                
                cdSafezone.name = safezone.name
                cdSafezone.active = safezone.active
                cdSafezone.shape = safezone.shape.rawValue
                
                let p1 = cdSafezone.point1
                let p2 = cdSafezone.point2
                
                if let point1 = safezone.point1 {
                    cdSafezone.point1 = point1
                }
                
                if let point2 = safezone.point2 {
                    cdSafezone.point2 = point2
                }
                if p1 == nil || p2 == nil || (p1 != nil && p2 != nil && (!p1!.isEqual(cdSafezone.point1) || !p2!.isEqual(cdSafezone.point2))) {
                    cdSafezone.preview = nil
                    cdSafezone.address = nil
                }
                
                CoreDataManager.instance.save(callback: { (error) in
                    if let error = error {
                        callback(error, nil)
                    } else {
                        callback(nil, cdSafezone)
                    }
                })
            }else{
                callback(DatabaseError(type: .Unknown, entity: .safeZone, action: .upsert, error: nil), nil)
            }
        }
    }
    
    func upsert(_ safezone: SafeZone, into petId: Int, callback: CDRepSafeZonesCallback? = nil) {
        
        getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                
                self.upsert(safezone, callback: { (error, cdSafezone) in
                    
                    if error == nil, let cdSafezone = cdSafezone {
                        let safezonesMutable = cdPet.mutableSetValue(forKeyPath: "safezones")
                        
                        
                        if ((safezonesMutable.allObjects as? [CDSafeZone])?.first(where: { $0.id == cdSafezone.id })) == nil {
                            safezonesMutable.add(cdSafezone)
                        }
                        cdPet.setValue(safezonesMutable, forKey: "safezones")
                        
                        CoreDataManager.instance.save(callback: { (error) in
                            if let error = error, let callback = callback {
                                callback(error, nil)
                            } else if let callback = callback {
                                callback(nil, (safezonesMutable.allObjects as? [CDSafeZone])?.map({ SafeZone($0) }))
                            }
                        })
                        
                    }else if let error = error, let callback = callback {
                        callback(error, nil)
                    }
                })
                
            }else if let error = error, let callback = callback {
                callback(error, nil)
            }else if let callback = callback {
                debugPrint(error ?? "nil error", cdPet ?? "nil pet")
                callback(DatabaseError(type: .Unknown, entity: .safeZone, action: .upsert, error: nil), nil)
            }
        }
    }
    
    func upsert(_ safezones: [SafeZone], into petId: Int) {
        self.getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                
                let safezonesMutable = cdPet.mutableSetValue(forKeyPath: "safezones")
                safezonesMutable.removeAllObjects()
                let group = DispatchGroup()
                for safezone in safezones {
                    group.enter()
                    self.upsert(safezone, callback: { (error, cdSafezone) in
                        if error == nil, let cdSafezone = cdSafezone {
                            safezonesMutable.add(cdSafezone)
                        }
                        group.leave()
                    })
                }
                group.notify(queue: .main, execute: { 
                    cdPet.setValue(safezonesMutable, forKey: "safezones")
                    CoreDataManager.instance.save(callback: { (error) in
                        if error != nil {
                            //                            callback(DatabaseError.Unknown, nil)
                        } else {
                            //                            callback(nil, Pet(cdPet))
                        }
                    })
                })
            }
        }
    }
    
    private func getSafeZoneCD(by id:Int, _ callback:@escaping (DatabaseError?, CDSafeZone?)->Void) {
        
        CoreDataManager.instance.retrieve(.safeZone, with: NSPredicate("id", .equal, id)) { (objects) in
            if let results = objects as? [CDSafeZone] {
                if results.count > 1 {
                    
                    callback(DatabaseError(type: .DuplicatedEntry, entity: .safeZone, action: .get, error: nil), nil)
                }else{
                    callback(nil, results.first!)
                }
            }else{
                callback(DatabaseError(type: .NotFound, entity: .safeZone, action: .get, error: nil), nil)
            }}
    }
    
    func setSafeZone(address: String, for id: Int, callback: @escaping CDRepErrorCallback){
        DispatchQueue.main.async {
            self.getSafeZoneCD(by: id) { (error, cdSafezone) in
                if error == nil, let cdSafezone = cdSafezone {
                    
                    cdSafezone.address = address
                    CoreDataManager.instance.save(callback: callback)
                }else if let error = error {
                    debugPrint(error)
                    callback(nil)
                }
            }
        }
        
    }
    
    func setSafeZone(imageData: Data, for id: Int, callback: @escaping CDRepErrorCallback){
        DispatchQueue.main.async {
            self.getSafeZoneCD(by: id) { (error, cdSafezone) in
                if error == nil, let cdSafezone = cdSafezone {
                    cdSafezone.preview = imageData
                    CoreDataManager.instance.save(callback: callback)
                }else if let error = error {
                    debugPrint(error)
                    callback(nil)
                }
            }
            
        }
        
    }
    
    //MARK:- Breeds
    
    func upsert(_ breeds: [Breed], for type:Type, callback: @escaping (Bool)->Void) {
        
        let group = DispatchGroup()
        
        for breed in breeds {
            group.enter()
            CoreDataManager.instance.upsert(.breed, with: ["id":breed.id, "type":type.rawValue], withRestriction: ["id","type"], callback: { (object) in
                if let cdBreed = object as? CDBreed {
                    cdBreed.type = type.rawValue
                    cdBreed.name = breed.name
                    CoreDataManager.instance.save(callback: { (error) in
                        if error != nil {
                            //                            callback(DatabaseError.Unknown, nil)
                        } else {
                            //                            callback(nil, Pet(cdPet))
                        }
                    })
                }
                group.leave()
            })
        }
        group.notify(queue: .main) { 
            callback(true)
        }
    }
    
    func getBreeds(for type:Type, callback: CDRepBreedsCallback? = nil) {
        
        CoreDataManager.instance.retrieve(.breed, with: NSPredicate("type", .equal, type.rawValue), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) { (objects) in
            if let breeds =  objects as? [CDBreed] {
                if let callback = callback { callback(nil, breeds.map({ Breed($0) })) }
            }else if let callback = callback {
                
                callback(DatabaseError(type: .NotFound, entity: Entity.breed, action: .get, error: nil), nil)
            }
        }
        
    }
    
    private func getBreedDB(for type:Type, breedId: Int, callback: @escaping (DatabaseError?, CDBreed?)-> Void) {

        CoreDataManager.instance.retrieve(.breed, with: NSPredicate("type", .equal, type.rawValue).and("id", .equal, breedId), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) { (objects) in
            if let breeds =  objects as? [CDBreed], breeds.count == 1 {
                callback(nil, breeds.first!)
            }else{
                callback(DatabaseError(type: .NotFound, entity: Entity.breed, action: .get, error: nil), nil)
            }
            
        }
        
    }
    
    func removeBreeds(for type:Type) {

        CoreDataManager.instance.delete(entity: .breed, withPredicate: NSPredicate("type", .equal, type.rawValue))
    }
    
    //MARK:- Country Codes
    
    func upsert(_ countryCode: CountryCode){

        CoreDataManager.instance.upsert(.countryCode, with: countryCode.toDict, withRestriction: ["name", "shortName"]) { (_) in }
    }
    
    func getCurrentCountryCode() -> String? {
        return Locale.current.regionCode
    }
    
    func getAllCountryCodes(callback: @escaping ([CountryCode]?)->Void) {
        
        CoreDataManager.instance.retrieve(.countryCode) { (objects) in
            if objects == nil || objects?.count == 0 {
                CSVParser.Instance.loadCountryCodes()
                CoreDataManager.instance.retrieve(.countryCode) { (objects) in
                    callback((objects as? [CDCountryCode])?.map({ CountryCode($0) }))
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
