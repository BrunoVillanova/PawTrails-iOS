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
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    let deviceCode = APIPetRegistrationTests().deviceCode
    let deviceCode2 = APIPetRegistrationTests().deviceCode2
    let takenDeviceCode = APIPetRegistrationTests().takenDeviceCode
    
    
    // MARK: - CheckDevice
    
    func testCheckDeviceOk() {
        
        let expect = expectation(description: "CheckDevice")
        
        DataManager.Instance.check(deviceCode) { (success) in
            XCTAssertTrue(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCheckDeviceDeviceIdNotFound() {
        
        let expect = expectation(description: "CheckDevice")
        
        DataManager.Instance.check("code") { (success) in
            XCTAssertFalse(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCheckDeviceDeviceNotAvailable() {
        
        let expect = expectation(description: "CheckDevice")
        
        DataManager.Instance.check(takenDeviceCode) { (success) in
            XCTAssertFalse(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
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
        waitForExpectations(timeout: 100) { error in
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
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
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
        waitForExpectations(timeout: 100) { error in
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
        waitForExpectations(timeout: 100) { error in
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
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
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
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    
    
    
    
    //    func testSetPetOk() {
    //
    //        let expect = expectation(description: "EditPetProfile")
    //
    //        PetManager.get { (error, pets) in
    //
    //
    //            XCTAssertNil(error, "Error \(String(describing: error))")
    //            XCTAssertNotNil(pets, "No data :(")
    //
    //            if let petId = pets?.first(where: { $0.isOwner})?.id {
    //
    //            var _data = [String:Any]()
    //            _data["name"] = "Paw"
    //            _data["type"] = "cat"
    //            _data["type_descr"] = ""
    //            _data["gender"] = "F"
    //            _data["breed"] = 204
    //            _data["breed1"] = 0
    //            _data["breed_descr"] = ""
    //            _data["date_of_birth"] = "2015-05-13"
    //            _data["weight"] = 2.3
    //            _data["neutered"] = false
    //
    //            DataManager.Instance.setpe
    //
    //            APIManager.Instance.perform(call: .setPet, withKey: petId, with: _data) { (error, data) in
    //                XCTAssertNil(error, "Error \(String(describing: error))")
    //                XCTAssertNotNil(data, "No data :(")
    //
    //                if let data = data {
    //                    self.check(in: _data, out: data)
    //                    expect.fulfill()
    //                }
    //            }
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    //    }
    //
    //    func check(in dataIn: [String:Any], out dataOut: [String:Any]){
    //
    //        assert(dataIn["name"] as! String == dataOut["name"] as! String)
    //        assert(dataIn["type"] as! String == dataOut["type"] as! String)
    //        if dataIn["type_descr"] != nil && dataIn["type_descr"] as! String != "" {
    //            assert(dataIn["type_descr"] as! String == dataOut["type_descr"] as! String)
    //        }
    //        assert(dataIn["gender"] as! String == dataOut["gender"] as! String)
    //        if dataIn["breed"] != nil && dataIn["breed"] as! Int != 0 {
    //            assert(dataIn["breed"] as! Int == dataOut["breed"] as! Int)
    //        }
    //        if dataIn["breed1"] != nil && dataIn["breed1"] as! Int != 0 {
    //            assert(dataIn["breed1"] as! Int == dataOut["breed1"] as! Int)
    //        }
    //        if dataIn["breed_descr"] != nil && dataIn["breed_descr"] as! String != "" {
    //            assert(dataIn["breed_descr"] as! String == dataOut["breed_descr"] as! String)
    //        }
    //        assert(dataIn["date_of_birth"] as! String == dataOut["date_of_birth"] as! String)
    //        assert(dataIn["weight"] as! Double == dataOut["weight"] as! Double)
    //        assert(dataIn["neutered"] as! Bool == dataOut["neutered"] as! Bool)
    //    }
    //
    //
    //
    
    
    func remove(_ petId: Int, _ callback: @escaping ((Bool)->())) {
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            callback(error == nil)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
