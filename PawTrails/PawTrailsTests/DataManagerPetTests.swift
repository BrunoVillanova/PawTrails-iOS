//
//  DataManagerPetTests.swift
//  PawTrails
//
//  Created by Marc Perello on 02/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails


class DataManagerPetTests: XCTestCase {
    
    override func setUp() {
        let expect = expectation(description: "Example")
        APIAuthenticationTests().signIn { (id, token) in
            SharedPreferences.set(.id, with: id)
            SharedPreferences.set(.token, with: token)
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    let deviceCode = APIPetRegistrationTests().deviceCode
    let deviceCode2 = APIPetRegistrationTests().deviceCode2
    let takenDeviceCode = APIPetRegistrationTests().takenDeviceCode
    
    func getPet(_ callback: @escaping ((Pet?)->())){
        DataManager.Instance.getPets { (error, pets) in
            callback(pets?.first(where: { $0.isOwner }))
        }
    }
    
    // MARK: - CheckDevice
    
    func testCheckDeviceOk() {
        
        let expect = expectation(description: "CheckDevice")
        
        DataManager.Instance.check(deviceCode) { (success) in
            XCTAssertTrue(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCheckDeviceDeviceIdNotFound() {
        
        let expect = expectation(description: "CheckDevice")
        
        DataManager.Instance.check("code") { (success) in
            XCTAssertFalse(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCheckDeviceDeviceNotAvailable() {
        
        let expect = expectation(description: "CheckDevice")
        
        DataManager.Instance.check(takenDeviceCode) { (success) in
            XCTAssertFalse(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    // MARK: - ChangeDevice
    
    func testChangeDeviceOk() {
        
        let expect = expectation(description: "ChangeDevice")
        
        APIManager.Instance.perform(call: .registerPet, with: ["device_code":deviceCode2, "name":"hey"]) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let petId = data?.tryCastInteger(for: "id") {
                
                DataManager.Instance.change(self.deviceCode, of: Int16(petId), callback: { (error) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    self.remove(petId, { (done) in
                        if done {
                            expect.fulfill()
                        }
                    })
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangeDeviceNotEnoughRights() {
        
        let expect = expectation(description: "ChangeDevice")
        
        DataManager.Instance.change(deviceCode2, of: -1, callback: { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights,"Error \(String(describing: error))")
            expect.fulfill()
            
        })
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangeDeviceNotEnoughRights2() {
        
        let expect = expectation(description: "ChangeDevice")
        
        APIManager.Instance.perform(call: .registerPet, with: ["device_code":deviceCode2, "name":"hey"]) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let petId = data?.tryCastInteger(for: "id") {
                DataManager.Instance.change(self.takenDeviceCode, of: -1, callback: { (error) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights,"Error \(String(describing: error))")
                    
                    self.remove(petId, { (done) in
                        if done {
                            expect.fulfill()
                        }
                    })
                })
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
        
    }
    
    // MARK: - Register
    
    func testRegisterCatOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var _data = [String:Any]()
        
        _data["device_code"] = deviceCode
        _data["name"] = "Paw"
        _data["type"] = Type.cat.name.lowercased()
        _data["gender"] = Gender.undefined.code
        _data["breed"] = 204
        _data["date_of_birth"] = "2015-12-13"
        _data["weight"] = 5.128
        _data["neutered"] = true
        
        DataManager.Instance.register(pet: _data) { (error, pet) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pet, "No data :(")
            
            if let pet = pet {
                XCTAssert(pet.name == _data["name"] as? String)
                XCTAssert(Type(rawValue: pet.type)?.name.lowercased() == _data["type"] as? String)
                XCTAssert(Gender(rawValue: pet.gender)?.code == _data["gender"] as? String)
                XCTAssert(pet.firstBreed?.id == Int16((_data["breed"] as? Int)!))
                XCTAssert(pet.birthday?.toStringServer == _data["date_of_birth"] as? String)
                XCTAssert(pet.weight == _data["weight"] as? Double)
                XCTAssert(pet.neutered == _data["neutered"] as? Bool)
                
                self.remove(Int(pet.id), { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
                
            }else{
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterDogOneOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var _data = [String:Any]()
        
        _data["device_code"] = deviceCode
        _data["name"] = "Paw"
        _data["type"] = "dog"
        _data["type_descr"] = ""
        _data["gender"] = "F"
        _data["breed"] = 5
        _data["breed_descr"] = ""
        _data["date_of_birth"] = "2015-05-13"
        _data["weight"] = 2.3
        _data["neutered"] = true
        
        DataManager.Instance.register(pet: _data) { (error, pet) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pet, "No data :(")
            
            if let pet = pet {
                XCTAssert(pet.name == _data["name"] as? String)
                XCTAssert(Type(rawValue: pet.type)?.name.lowercased() == _data["type"] as? String)
                XCTAssert(pet.type_descr == _data["type_descr"] as? String)
                XCTAssert(Gender(rawValue: pet.gender)?.code == _data["gender"] as? String)
                XCTAssert(pet.firstBreed?.id == Int16(_data["breed"] as! Int))
                XCTAssert(pet.breed_descr == _data["breed_descr"] as? String)
                XCTAssert(pet.birthday?.toStringServer == _data["date_of_birth"] as? String)
                XCTAssert(pet.weight == _data["weight"] as? Double)
                XCTAssert(pet.neutered == _data["neutered"] as? Bool)
                
                self.remove(Int(pet.id), { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
                
            }else{
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterDogTwoOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var _data = [String:Any]()
        
        _data["device_code"] = deviceCode
        _data["name"] = "Paw"
        _data["type"] = "dog"
        _data["type_descr"] = ""
        _data["gender"] = "F"
        _data["breed"] = 5
        _data["breed1"] = 6
        _data["breed_descr"] = ""
        _data["date_of_birth"] = "2015-05-13"
        _data["weight"] = 2.3
        _data["neutered"] = true
        
        DataManager.Instance.register(pet: _data) { (error, pet) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pet, "No data :(")
            
            if let pet = pet {
                XCTAssert(pet.name == _data["name"] as? String)
                XCTAssert(Type(rawValue: pet.type)?.name.lowercased() == _data["type"] as? String)
                XCTAssert(pet.type_descr == _data["type_descr"] as? String)
                XCTAssert(Gender(rawValue: pet.gender)?.code == _data["gender"] as? String)
                XCTAssert(pet.firstBreed?.id == Int16(_data["breed"] as! Int))
                XCTAssert(pet.secondBreed?.id == Int16(_data["breed1"] as! Int))
                XCTAssert(pet.breed_descr == _data["breed_descr"] as? String)
                XCTAssert(pet.birthday?.toStringServer == _data["date_of_birth"] as? String)
                XCTAssert(pet.weight == _data["weight"] as? Double)
                XCTAssert(pet.neutered == _data["neutered"] as? Bool)
                
                self.remove(Int(pet.id), { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
                
            }else{
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterOtherOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var _data = [String:Any]()
        
        _data["device_code"] = deviceCode
        _data["name"] = "Paw"
        _data["gender"] = "F"
        _data["type"] = "other"
        _data["type_descr"] = "Horse"
        _data["breed_descr"] = "Percheron"
        _data["date_of_birth"] = "2015-12-13"
        _data["weight"] = 5000.95
        _data["neutered"] = true
        
        DataManager.Instance.register(pet: _data) { (error, pet) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pet, "No data :(")
            
            if let pet = pet {
                XCTAssert(pet.name == _data["name"] as? String)
                XCTAssert(Type(rawValue: pet.type)?.name.lowercased() == _data["type"] as? String)
                XCTAssert(pet.type_descr == _data["type_descr"] as? String)
                XCTAssert(Gender(rawValue: pet.gender)?.code == _data["gender"] as? String)
                XCTAssert(pet.breed_descr == _data["breed_descr"] as? String)
                XCTAssert(pet.birthday?.toStringServer == _data["date_of_birth"] as? String)
                XCTAssert(pet.weight == _data["weight"] as? Double)
                XCTAssert(pet.neutered == _data["neutered"] as? Bool)
                
                self.remove(Int(pet.id), { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
                
            }else{
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterDateOfBirth() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["name"] = "Paw"
        data["type"] = "cat"
        data["type_descr"] = ""
        data["gender"] = "F"
        data["date_of_birth"] = "2015-05-13p"
        data["weight"] = 2.3
        data["neutered"] = false
        
        DataManager.Instance.register(pet: data) { (error, pet) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterGenderFormat() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["name"] = "Paw"
        data["type"] = "cat"
        data["type_descr"] = ""
        data["gender"] = 25
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutered"] = false
        
        DataManager.Instance.register(pet: data) { (error, pet) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterWrongBreed() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["name"] = "Paw"
        data["type"] = "cat"
        data["type_descr"] = ""
        data["gender"] = "F"
        data["breed"] = -3
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutered"] = false
        
        DataManager.Instance.register(pet: data) { (error, pet) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.WrongBreed, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterMissingPetName() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["type"] = "cat"
        data["type_descr"] = ""
        data["gender"] = "F"
        data["breed"] = 204
        data["breed_descr"] = ""
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutered"] = false
        
        DataManager.Instance.register(pet: data) { (error, pet) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPetName, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterWeightOutOfRange() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["name"] = "Paw"
        data["type"] = "cat"
        data["type_descr"] = ""
        data["gender"] = "F"
        data["breed"] = 204
        data["breed_descr"] = ""
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = Constants.maxWeight + 1
        data["neutered"] = false
        
        DataManager.Instance.register(pet: data) { (error, pet) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.WeightOutOfRange, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
   
    // MARK: - GetPet
    
    func testGetPetOk() {
        
        let expect = expectation(description: "GetPet")
        
        PetManager.get { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first?.id {
                
                DataManager.Instance.getPet(petId, callback: { (error, pet) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(pet)
                    
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testGetPetNotFound() {
        
        let expect = expectation(description: "GetPet")
        

        DataManager.Instance.getPet(-1, callback: { (error, pet) in
            
            XCTAssertNil(pet)
            XCTAssertNotNil(error)
            XCTAssert(error?.DBError == DatabaseError.NotFound)
            
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    // MARK: - LoadPet
    
    func testLoadPetOk() {
        
        let expect = expectation(description: "LoadPet")
        
        PetManager.get { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first?.id {
                
                DataManager.Instance.loadPet(petId, callback: { (error, pet) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(pet)
                    
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadPetNotEnoughRights() {
        
        let expect = expectation(description: "LoadPet")
        
        
        DataManager.Instance.loadPet(-1, callback: { (error, pet) in
            
            XCTAssertNil(pet)
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, String(describing: error))
            
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    // MARK: - RemovePet
    
    func testRemoveOk() {
        
//        let expect = expectation(description: "RemovePet")
//        
//        PetManager.get { (error, pets) in
//            
//            XCTAssertNil(error, "Error \(String(describing: error))")
//            XCTAssertNotNil(pets)
//            
//            if let petId = pets?.first?.id {
//                
//                DataManager.Instance.removePet(petId, callback: { (error) in
//                    
//                    XCTAssertNil(error, "Error \(String(describing: error))")
//                    expect.fulfill()
//                })
//            }
//        }
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    func testRemoveNotEnoughRights() {
        
        let expect = expectation(description: "RemovePet")
        
        DataManager.Instance.removePet(-1, callback: { (error) in
            
            XCTAssertNotNil(error, "Error \(String(describing: error))")
            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, "Error \(String(describing: error))")
            
            expect.fulfill()
        })
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    // MARK: - GetPets
    
    func testGetPetsOk() {
        
        let expect = expectation(description: "GetPets")
        
        DataManager.Instance.getPets { (error, pets) in
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testGetPetsNotFound() {
        
        let expect = expectation(description: "GetPets")
        
        do {
            try CoreDataManager.Instance.delete(entity: "Pet")
            
            DataManager.Instance.getPets { (error, pets) in
                XCTAssertNil(pets)
                XCTAssertNotNil(error, "Error \(String(describing: error))")
                XCTAssert(error?.DBError == DatabaseError.NotFound)
                
                DataManager.Instance.loadPets(callback: { (error, pets) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(pets)
                    expect.fulfill()
                })
            }
            
        } catch {
            XCTFail(String(describing: error))
        }
        
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    
    // MARK: - GetPetsSplitted
    
    func testGetPetsSplittedOk() {
        
        let expect = expectation(description: "GetPetsSplitted")
        
        DataManager.Instance.getPetsSplitted { (error, owned, shared) in
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(owned)
            XCTAssertNotNil(shared)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testGetPetsSplittedNotFound() {
        
        let expect = expectation(description: "GetPetsSplitted")
        
        do {
            try CoreDataManager.Instance.delete(entity: "Pet")
            
            DataManager.Instance.getPetsSplitted { (error, owned, shared) in
                XCTAssertNil(owned)
                XCTAssertNil(shared)
                XCTAssertNotNil(error, "Error \(String(describing: error))")
                XCTAssert(error?.DBError == DatabaseError.NotFound)
                
                DataManager.Instance.loadPets(callback: { (error, pets) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(pets)
                    expect.fulfill()
                })
            }
            
        } catch {
            XCTFail(String(describing: error))
        }
        
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    // MARK: - LoadPets
    
    func testLoadPetsOk() {
        let expect = expectation(description: "LoadPets")
        
        DataManager.Instance.loadPets { (error, pets) in
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadPetsAnauthorized() {
        let expect = expectation(description: "LoadPets")
        
        if let token = SharedPreferences.get(.token) {
            
            _ = SharedPreferences.remove(.token)
            
            DataManager.Instance.loadPets { (error, pets) in
                XCTAssertNil(pets)
                XCTAssertNotNil(error)
                XCTAssert(error?.APIError?.errorCode == ErrorCode.Unauthorized, "Error \(String(describing: error))")
                SharedPreferences.set(.token, with: token)
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    // MARK: - SetPet
    
    func testSetPetCatOk() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "cat"
                data["type_descr"] = ""
                data["gender"] = "F"
                data["breed"] = 204
                data["breed1"] = 0
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13"
                data["weight"] = 2.3
                data["neutered"] = false
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetPetDogOneOk() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "dog"
                data["type_descr"] = ""
                data["gender"] = "F"
                data["breed"] = 5
                data["breed1"] = 0
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13"
                data["weight"] = 2.3
                data["neutered"] = true
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetPetDogTwoOk() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "dog"
                data["type_descr"] = ""
                data["gender"] = "F"
                data["breed"] = 5
                data["breed1"] = 6
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13"
                data["weight"] = 2.3
                data["neutered"] = true
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetPetOthetOk() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "other"
                data["type_descr"] = "Horse"
                data["gender"] = "U"
                data["breed"] = 0
                data["breed1"] = 0
                data["breed_descr"] = "Percheron"
                data["date_of_birth"] = "2015-12-13"
                data["weight"] = 5000.95
                data["neutered"] = true
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetPetDateOfBirth() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "cat"
                data["type_descr"] = ""
                data["gender"] = "F"
                data["breed"] = 0
                data["breed1"] = 0
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13p"
                data["weight"] = 2.3
                data["neutered"] = false
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNotNil(error, "Error \(String(describing: error))")
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetPetGenderFormat() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "cat"
                data["type_descr"] = ""
                data["gender"] = 25
                data["breed"] = 0
                data["breed1"] = 0
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13"
                data["weight"] = 2.3
                data["neutered"] = false
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNotNil(error, "Error \(String(describing: error))")
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetPetWrongBreed() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "cat"
                data["type_descr"] = ""
                data["gender"] = "F"
                data["breed"] = -2
                data["breed1"] = 0
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13"
                data["weight"] = 2.3
                data["neutered"] = false
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNotNil(error, "Error \(String(describing: error))")
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.WrongBreed, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetPetMissingPetName() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                //                data["name"] = "Paw"
                data["type"] = "cat"
                data["type_descr"] = ""
                data["gender"] = "F"
                data["breed"] = -2
                data["breed1"] = 0
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13"
                data["weight"] = 2.3
                data["neutered"] = false
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNotNil(error, "Error \(String(describing: error))")
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPetName, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetWeightOutOfRange() {
        let expect = expectation(description: "SetPet")
        
        self.getPet { (pet) in
            
            if let petId = pet?.id {
                
                var data = [String:Any]()
                
                data["name"] = "Paw"
                data["type"] = "cat"
                data["type_descr"] = ""
                data["gender"] = "F"
                data["breed"] = 204
                data["breed1"] = 0
                data["breed_descr"] = ""
                data["date_of_birth"] = "2015-05-13"
                data["weight"] = Constants.maxWeight + 1
                data["neutered"] = false
                
                DataManager.Instance.setPet(petId, data, callback: { (error) in
                    XCTAssertNotNil(error, "Error \(String(describing: error))")
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.WeightOutOfRange, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetNotFound() {
        let expect = expectation(description: "SetPet")
        

        var data = [String:Any]()
        
        data["name"] = "Paw"
        
        DataManager.Instance.setPet(0, data, callback: { (error) in
            XCTAssertNotNil(error, "Error \(String(describing: error))")
            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotFound, "Wrong Error \(String(describing: error))")
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    // MARK: - GetBreeds
    
    func testGetBreedsCatOk(){
        let expect = expectation(description: "GetBreeds")
        
        DataManager.Instance.getBreeds(for: .cat) { (error, breeds) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(breeds)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testGetBreedsDogOk(){
        let expect = expectation(description: "GetBreeds")
        
        DataManager.Instance.getBreeds(for: .dog) { (error, breeds) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(breeds)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testGetBreedsNotFound(){
        let expect = expectation(description: "GetBreeds")
        
        DataManager.Instance.getBreeds(for: .other) { (error, breeds) in
            
            XCTAssertNotNil(error, "Error \(String(describing: error))")
            XCTAssert(error?.DBError == DatabaseError.NotFound, "Error \(String(describing: error))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    // MARK: - LoadBreeds
    
    func testLoadBreedsCatOk() {
        let expect = expectation(description: "LoadBreeds")
        
        let type = Type.cat
        
        DataManager.Instance.loadBreeds(for: type) { (error, breeds) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(breeds)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadBreedsDogOk() {
        let expect = expectation(description: "LoadBreeds")
        
        let type = Type.dog
        
        DataManager.Instance.loadBreeds(for: type) { (error, breeds) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(breeds)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadBreedsNotFound() {
        let expect = expectation(description: "LoadBreeds")
        
        let type = Type.other
        
        DataManager.Instance.loadBreeds(for: type) { (error, breeds) in
            
            XCTAssertNotNil(error, "Error \(String(describing: error))")
            XCTAssert(error?.DBError == DatabaseError.NotFound, "Error \(String(describing: error))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func remove(_ petId: Int, _ callback: @escaping ((Bool)->())) {
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            callback(error == nil)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
