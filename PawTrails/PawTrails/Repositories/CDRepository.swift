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
        
        CoreDataManager.Instance.upsert("CDUser", with: ["id":user.id]) { (object) in

            if let cdUser = object as? CDUser {
                
                cdUser.name = user.name
                cdUser.surname = user.surname
                cdUser.email = user.email
                cdUser.notification = user.notification
                cdUser.birthday = user.birthday
                cdUser.gender = user.gender?.rawValue ?? Int16(-1.0)
                
                // Address
                
                if let address = user.address {
                    
                    if cdUser.address == nil { // Create
                        cdUser.address = try CoreDataManager.Instance.store("CDAddress", with: ["city":""]) as? CDAddress
                    }
                    cdUser.address?.city = address.city
                    cdUser.address?.country = address.country
                    cdUser.address?.line0 = address.line0
                    cdUser.address?.line1 = address.line1
                    cdUser.address?.line2 = address.line2
                    cdUser.address?.postal_code = address.postalCode
                    cdUser.address?.state = address.state

                }else{ //Remove
                    cdUser.setValue(nil, forKey: "address")
                }
                
                // Phone
                
                if let phone = user.phone {
                    
                    if cdUser.phone == nil { // Create
                        cdUser.phone = try CoreDataManager.Instance.store("CDPhone", with: ["number":""]) as? CDPhone
                    }
                    cdUser.phone?.number = phone.number
                    cdUser.phone?.country_code = phone.countryCode
                    
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
                
                CoreDataManager.Instance.save(callback: { (error) in
                    if let error = error {
                        callback(DatabaseError.Unknown, nil)
                    } else {
                        callback(nil, User(cdUser))
                    }
                })
            }
        }
    }
    
    private func getUserCD(by id: Int, _ callback:(DatabaseError?, CDUser?)->Void) {
        
        if let results = CoreDataManager.Instance.retrieve("CDUser", with: NSPredicate("id", .equal, id)) as? [CDUser] {
            if results.count > 1 {
                callback(DatabaseError.DuplicatedEntry, nil)
            }else{
                callback(nil, results.first!)
            }
        }else{
            callback(DatabaseError.NotFound, nil)
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
    
    func removeUser(by id: Int) -> Bool {
        do {
            try CoreDataManager.Instance.delete(entity: "CDUser", withPredicate: NSPredicate("id", .equal, id))
            return true
        } catch {}
        return false
    }

    //MARK:- Pet
    
    func upsert(_ pet: Pet) -> Pet? {
        
        do {
            if let cdPet = try CoreDataManager.Instance.upsert("CDPet", with: ["id":pet.id]) as? CDPet {
                
                cdPet.name = pet.name
                cdPet.weight = pet.weight ?? 0.0
                cdPet.neutered = pet.neutered
                cdPet.birthday = pet.birthday
                cdPet.isOwner =  pet.isOwner
                cdPet.type = pet.type?.type?.rawValue ?? Int16(-1.0)
                cdPet.gender = pet.gender?.rawValue ?? Int16(-1.0)
                
                // Breeds
                if let type = Type(rawValue: cdPet.type) {
                    
                    // First Breed
                    if let firstBreedId = pet.breeds?.breeds[0] {
                        getBreedDB(for: type, breedId: firstBreedId, callback: { (error, breed) in
                            if error == nil { cdPet.firstBreed = breed }
                        })
                    }else{
                        cdPet.setValue(nil, forKey: "firstBreed")
                    }
                    
                    // Second Breed
                    if let secondBreedId = pet.breeds?.breeds[1] {
                        getBreedDB(for: type, breedId: secondBreedId, callback: { (error, breed) in
                            if error == nil { cdPet.secondBreed = breed }
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
                try CoreDataManager.Instance.save()

                return Pet(cdPet)
            }
            
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    func upsert(_ pets: [Pet]) -> [Pet]? {
        var updatedPets = [Pet]()
        if let localpets = getPets() {
            
            var localpetIDs = localpets.map({ $0.id })
            //Update
            for pet in pets {
                if let index = localpetIDs.index(of: pet.id) {
                    localpetIDs.remove(at: index)
                }
                if let pet = upsert(pet) { updatedPets.append(pet) }
                else { return nil }
            }
            //Remove
            for id in localpetIDs {
                if !removePet(by: id) { return nil }
            }
            return updatedPets
        }else{
            for pet in pets {
                if let pet = upsert(pet) { updatedPets.append(pet) }
                else { return nil }
            }
            return updatedPets
        }
    }
    
    func savePet(_ deviceCode: String, _ id: Int, _ callback: @escaping CDRepErrorCallback){
        
        getPetCD(by: id) { (error, pet) in
            if let pet = pet {
                do {
                    pet.deviceCode = deviceCode
                    try CoreDataManager.Instance.save()
                    callback(nil)
                }catch {
                    debugPrint(error)
                    callback(DatabaseError.Unknown)
                }

            }else if let error = error {
                callback(error)
            }
        }
    }
    
    private func getPetCD(by id:Int, _ callback: @escaping (DatabaseError?, CDPet?)-> Void) {
        
        if let results = CoreDataManager.Instance.retrieve("CDPet", with: NSPredicate("id", .equal, id)) as? [CDPet] {
            if results.count > 1 {
                callback(DatabaseError.DuplicatedEntry, nil)
            }else{
                callback(nil, results.first!)
            }
        }else{
            callback(DatabaseError.NotFound, nil)
        }
    }
    
    func getPet(by id:Int, _ callback:CDRepPetCallback) {
        
        if let results = CoreDataManager.Instance.retrieve("CDPet", with: NSPredicate("id", .equal, id)) as? [CDPet] {
            if results.count > 1 {
                callback(DatabaseError.DuplicatedEntry, nil)
            }else{
                callback(nil, Pet(results.first!))
            }
        }else{
            callback(DatabaseError.NotFound, nil)
        }
    }
    
    func getPets() -> [Pet]? {
        return (CoreDataManager.Instance.retrieve("CDPet", sortedBy: [NSSortDescriptor(key: "name", ascending: true)]) as? [CDPet])?.map({ Pet($0) })
    }
    
    func removePet(by id: Int) -> Bool {
        do {
            try CoreDataManager.Instance.delete(entity: "CDPet", withPredicate: NSPredicate("id", .equal, id))
            return true
        } catch {
            debugPrint(error)
        }
        return false
    }

    //MARK:- PetUser
    
    private func upsert(_ petUser: PetUser) -> CDPetUser? {
        
        do {

            if let user = try CoreDataManager.Instance.upsert("CDPetUser", with: ["id":petUser.id]) as? CDPetUser {
                
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
                return user
            }
            
        } catch {
            debugPrint(error)
        }
        return nil
    }

    func upsert(_ petUser: PetUser, into petId: Int, callback: CDRepPetUserCallback? = nil){
        
        
        getPetCD(by: petId) { (error, cdPet) in

            if error == nil, let cdPet = cdPet {
                do {
                    let users = cdPet.mutableSetValue(forKey: "users")
                    
                    if let cdPetUser = self.upsert(petUser) {
                        
                        if (users.allObjects as? [CDPetUser])?.first(where: { $0.id == cdPetUser.id }) == nil {
                            users.add(cdPetUser)
                        }
                        
                        cdPet.setValue(users, forKey: "users")
                        
                        try CoreDataManager.Instance.save()
                        
                        if let callback = callback { callback(nil, PetUser(cdPetUser)) }

                    }else{
                        if let callback = callback { callback(DatabaseError.Unknown, nil)}
                        return
                    }
                    
                }catch{
                    debugPrint(error)
                    if let callback = callback { callback(DatabaseError.Unknown, nil) }
                }
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
                do {
                    let users = cdPet.mutableSetValue(forKey: "users")
                    users.removeAllObjects()
                    
                    for petUser in petUsers {
                        if let cdPetUser = self.upsert(petUser) { users.add(cdPetUser) }
                    }
                    cdPet.setValue(users, forKey: "users")
                    try CoreDataManager.Instance.save()
                    
                    if let callback = callback { callback(nil, (users.allObjects as? [CDPetUser])?.map({ PetUser($0) })) }
                }catch{
                    debugPrint(error)
                    if let callback = callback { callback(DatabaseError.Unknown, nil) }
                }
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
                callback(DatabaseError.Unknown, nil)
            }
        }
    }

    func removeSharedPetUser(with id: Int, from petId: Int, callback: @escaping CDRepErrorCallback){
        
        getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                if let user = (cdPet.users?.allObjects as? [CDPetUser])?.first(where: { $0.id == id.toInt16 }) {
                    do {
                        
                        user.removeFromPetUsers(cdPet)
                        try CoreDataManager.Instance.save()
                        callback(nil)
                    }catch{
                        debugPrint(error)
                        callback(DatabaseError.Unknown)
                    }
                    
                }else{
                    callback(DatabaseError.NotFound)
                }
                
            }else if let error = error {
                callback(error)
            }else {
                debugPrint(error ?? "error nil", cdPet ?? "pet nil")
                callback(DatabaseError.Unknown)
            }
        }
        
    }
    
    func upsertUser(_ friends: [PetUser], into id: Int, callback: CDRepPetUsersCallback? = nil){
        
        getUserCD(by: id) { (error, cdUser) in
            
            if let cdUser = cdUser {
                do {
                    let cdFriends = cdUser.mutableSetValue(forKey: "friends")
                    cdFriends.removeAllObjects()
                    
                    for friend in friends {
                        if let petUser = upsert(friend) {
                            if petUser.email != nil { cdFriends.add(petUser) }
                        }
                    }
                    cdUser.setValue(cdFriends, forKey: "friends")
                    try CoreDataManager.Instance.save()
                    if let callback = callback {
                        if let cdFriends = cdFriends.allObjects as? [CDPetUser] {
                            callback(nil, cdFriends.map({ PetUser($0) }))
                        }
                        callback(nil, nil)
                    }
                }catch{
                    debugPrint(error)
                    if let callback = callback { callback(DatabaseError.Unknown, nil) }
                }
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
                callback(DatabaseError.NotFound, nil)
            }
        }
    }

    
    
    //MARK:- SafeZones
    
    private func upsert(_ safezone: SafeZone, callback: @escaping (DatabaseError?, CDSafeZone?)->Void) {
        
        do {
            if let cdSafezone = try CoreDataManager.Instance.upsert("CDSafeZone", with: ["id":safezone.id]) as? CDSafeZone {
                
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
                
                try CoreDataManager.Instance.save()
                callback(nil, cdSafezone)
            }else{
                callback(DatabaseError.Unknown, nil)
            }
        } catch {
            debugPrint(error)
            callback(DatabaseError.Unknown, nil)
        }
    }

    func upsert(_ safezone: SafeZone, into petId: Int, callback: CDRepSafeZonesCallback? = nil) {
        
        getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                
                self.upsert(safezone, callback: { (error, cdSafezone) in
                    
                    if error == nil, let cdSafezone = cdSafezone {
                        do {
                            let safezonesMutable = cdPet.mutableSetValue(forKeyPath: "safezones")

                            
                            if ((safezonesMutable.allObjects as? [CDSafeZone])?.first(where: { $0.id == cdSafezone.id })) == nil {
                                safezonesMutable.add(cdSafezone)
                            }
                            cdPet.setValue(safezonesMutable, forKey: "safezones")
                            
                            try CoreDataManager.Instance.save()

                            if let callback = callback { callback(nil, (safezonesMutable.allObjects as? [CDSafeZone])?.map({ SafeZone($0) })) }
                        }catch{
                            debugPrint(error)
                            if let callback = callback { callback(DatabaseError.Unknown, nil) }
                        }
                    }else if let error = error, let callback = callback {
                        callback(error, nil)
                    }
                })
                
            }else if let error = error, let callback = callback {
                callback(error, nil)
            }else if let callback = callback {
                debugPrint(error ?? "nil error", cdPet ?? "nil pet")
                callback(DatabaseError.Unknown, nil)
            }
        }
    }
    
    func upsert(_ safezones: [SafeZone], into petId: Int) {
        DispatchQueue.main.async {
        self.getPetCD(by: petId) { (error, cdPet) in
            if error == nil, let cdPet = cdPet {
                do {
                    
                    let safezonesMutable = cdPet.mutableSetValue(forKeyPath: "safezones")
                    safezonesMutable.removeAllObjects()
                    
                    for safezone in safezones {
                        self.upsert(safezone, callback: { (error, cdSafezone) in
                            if error == nil, let cdSafezone = cdSafezone {
                                safezonesMutable.add(cdSafezone)
                            }
                        })
                    }
                    cdPet.setValue(safezonesMutable, forKey: "safezones")
                    try CoreDataManager.Instance.save()
                }catch{
                    debugPrint(error)
                }
            }
        }
        }
    }
    
    private func getSafeZoneCD(by id:Int, _ callback:@escaping (DatabaseError?, CDSafeZone?)->Void) {
        
        if let results = CoreDataManager.Instance.retrieve("CDSafeZone", with: NSPredicate("id", .equal, id)) as? [CDSafeZone] {
            if results.count > 1 {
                callback(DatabaseError.DuplicatedEntry, nil)
            }else{
                callback(nil, results.first!)
            }
        }else{
            callback(DatabaseError.NotFound, nil)
        }
    }

    func setSafeZone(address: String, for id: Int){
        DispatchQueue.main.async {
        self.getSafeZoneCD(by: id) { (error, cdSafezone) in
            if error == nil, let cdSafezone = cdSafezone {
                do {
                    cdSafezone.address = address
                    try CoreDataManager.Instance.save()
                }catch{
                    debugPrint(error)
                }
            }else if let error = error {
                debugPrint(error)
            }
        }
        }
    }
    
    func setSafeZone(imageData: Data, for id: Int){
        DispatchQueue.main.async {
        self.getSafeZoneCD(by: id) { (error, cdSafezone) in
            if error == nil, let cdSafezone = cdSafezone {
                do {
                    cdSafezone.preview = imageData
                    try CoreDataManager.Instance.save()
                }catch{
                    debugPrint(error)
                }
            }else if let error = error {
                debugPrint(error)
            }
        }
        }
    }
    
    //MARK:- Breeds
    
    func upsert(_ breeds: [Breed], for type:Type) -> Bool {
        
        do {
            for breed in breeds {
                
                if let cdBreed = try CoreDataManager.Instance.upsert("CDBreed", with: ["id":breed.id, "type":type.rawValue], withRestriction: ["id","type"]) as? CDBreed {
                    cdBreed.type = type.rawValue
                    cdBreed.name = breed.name
                    try CoreDataManager.Instance.save()
                }
            }
            return true
        } catch {
            debugPrint(error)
        }
        return false
    }
    
    func getBreeds(for type:Type, callback: CDRepBreedsCallback? = nil) {
        if let breeds =  CoreDataManager.Instance.retrieve("CDBreed", with: NSPredicate("type", .equal, type.rawValue), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [CDBreed] {
            if let callback = callback { callback(nil, breeds.map({ Breed($0) })) }
        }else if let callback = callback {
            callback(DatabaseError.NotFound, nil)
        }
    }
    
    private func getBreedDB(for type:Type, breedId: Int, callback: @escaping (DatabaseError?, CDBreed?)-> Void) {
        if let breeds =  CoreDataManager.Instance.retrieve("CDBreed", with: NSPredicate("type", .equal, type.rawValue).and("id", .equal, breedId), sortedBy: [NSSortDescriptor.init(key: "name", ascending: true)]) as? [CDBreed] {
            if breeds.count == 1 {
                callback(nil, breeds.first!)
            }else{
                callback(DatabaseError.DuplicatedEntry, nil)
            }
        }else{
//            DataManager.Instance.loadBreeds(for: type, callback: { (error, breeds) in
//                if error == nil, let breeds = breeds {
//                    callback(nil, breeds.first(where: { $0.id == Int(breedId) && $0.type == type.rawValue}))
//                }else{
//                    callback(DataManagerError(DBError: DatabaseError.NotFound), nil)
//                }
//            })
        }
    }
    
    func removeBreeds(for type:Type) {
        do {
            try CoreDataManager.Instance.delete(entity: "CDBreed", withPredicate: NSPredicate("type", .equal, type.rawValue))
        } catch {
            debugPrint(error)
        }
    }


    //MARK:- Country Codes
    
    func getCurrentCountryCode() -> String? {
        return Locale.current.regionCode
    }
    
    func getAllCountryCodes() -> [CountryCode]? {
        let results = CoreDataManager.Instance.retrieve("CDCountryCode") as? [CDCountryCode]
        if results == nil || results?.count == 0 {
            CSVParser.Instance.loadCountryCodes()
            return (CoreDataManager.Instance.retrieve("CDCountryCode") as? [CDCountryCode])?.map({ CountryCode($0) })
        }
        return results?.map({ CountryCode($0) })
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
