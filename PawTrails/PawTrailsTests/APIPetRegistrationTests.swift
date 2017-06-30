//
//  APIPetTests.swift
//  PawTrails
//
//  Created by Marc Perello on 24/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails


class APIPetRegistrationTests: XCTestCase {
    
    let deviceCode = "VhfOoZhZg3Jc"
    let deviceCode2 = "EZT7JlkOZfql"
    let takenDeviceCode = "niAy82KhGRdy"
    
    override func setUp() {
        let expect = expectation(description: "Example")
        APIAuthenticationTests().signIn { () in
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- Check
    
    func testCheckDeviceOk() {
        
        let expect = expectation(description: "CheckDevice")
        
        APIManager.Instance.perform(call: .checkDevice, withKey: deviceCode) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssert(data?["available"].bool ?? false , "Not Available")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCheckDeviceDeviceIdNotFound() {
        
        let expect = expectation(description: "CheckDevice")
        
        APIManager.Instance.perform(call: .checkDevice, withKey: "kl") { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.DeviceIdNotFound, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCheckDeviceDeviceNotAvailable() {
        
        let expect = expectation(description: "CheckDevice")
        
        APIManager.Instance.perform(call: .checkDevice, withKey: takenDeviceCode) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssert(data?["available"].boolValue ?? false, "Available")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- Change
    
    func testChangeDeviceOk() {
        
        let expect = expectation(description: "ChangeDevice")
        
        APIManager.Instance.perform(call: .registerPet, with: ["device_code":deviceCode2, "name":"hey"]) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let petId = data?["id"].int {
                
                APIManager.Instance.perform(call: .changeDevice, withKey: petId, with: ["device_code": self.deviceCode], callback: { (error, data) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
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
        
        APIManager.Instance.perform(call: .changeDevice, withKey: -1, with: ["device_code": self.deviceCode], callback: { (error, data) in
            
            XCTAssertNil(data)
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.NotEnoughRights,"Error \(String(describing: error))")
            expect.fulfill()
            
        })
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangeDeviceDeviceNotAvailable() {
        
        let expect = expectation(description: "ChangeDevice")
        
        APIManager.Instance.perform(call: .registerPet, with: ["device_code":deviceCode2, "name":"hey"]) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let petId = data?["id"].int {
                APIManager.Instance.perform(call: .changeDevice, withKey: petId, with: ["device_code": self.takenDeviceCode], callback: { (error, data) in
                    
                    XCTAssertNil(data)
                    XCTAssertNotNil(error)
                    XCTAssert(error?.errorCode == ErrorCode.DeviceNotAvailable)
                    
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
    
    
    //MARK:- RegisterPet
    
    func testRegisterCatOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var _data = [String:Any]()
        
        _data["device_code"] = deviceCode
        _data["name"] = "Paw"
        _data["type"] = Type.cat.name.lowercased()
        _data["gender"] = "U"
        _data["breed"] = 204
        _data["date_of_birth"] = "2015-12-13"
        _data["weight"] = 5.128
        _data["neutered"] = true
        
        APIManager.Instance.perform(call: .registerPet, with: _data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let data = data {
                XCTAssert(data["name"].string == _data["name"] as? String, "name")
                XCTAssert(data["type"].string == _data["type"] as? String, "type")
                XCTAssert(data["gender"].string == _data["gender"] as? String, "gender")
                XCTAssert(data["breed"].int == _data["breed"] as? Int, "breed")
                XCTAssert(data["date_of_birth"].string == _data["date_of_birth"] as? String, "date_of_birth")
                XCTAssert(data["neutered"].bool == _data["neutered"] as? Bool, "neutered")
            }else{
                XCTFail()
            }
            
            
            if let id = data?["id"].int {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
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
        
        APIManager.Instance.perform(call: .registerPet, with: _data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let data = data {
                XCTAssert(data["name"].string == _data["name"] as? String, "name")
                XCTAssert(data["type"].string == _data["type"] as? String, "type")
                XCTAssert(data["type_descr"].string == _data["type_descr"] as? String, "type_descr")
                XCTAssert(data["gender"].string == _data["gender"] as? String, "gender")
                XCTAssert(data["breed"].int == _data["breed"] as? Int, "breed")
                XCTAssert(data["breed_descr"].string == _data["breed_descr"] as? String, "breed_descr")
                XCTAssert(data["date_of_birth"].string == _data["date_of_birth"] as? String, "date_of_birth")
                XCTAssert(data["weight"].double == _data["weight"] as? Double, "weight")
                XCTAssert(data["neutered"].bool == _data["neutered"] as? Bool, "neutered")
            }else{
                XCTFail()
            }
            
            if let id = data?["id"].int {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
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
        
        
        APIManager.Instance.perform(call: .registerPet, with: _data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let data = data {
                XCTAssert(data["name"].string == _data["name"] as? String, "name")
                XCTAssert(data["type"].string == _data["type"] as? String, "type")
                XCTAssert(data["type_descr"].string == _data["type_descr"] as? String, "type_descr")
                XCTAssert(data["gender"].string == _data["gender"] as? String, "gender")
                XCTAssert(data["breed"].int == _data["breed"] as? Int, "breed")
                XCTAssert(data["breed1"].int == _data["breed1"] as? Int, "breed1")
                XCTAssert(data["breed_descr"].string == _data["breed_descr"] as? String, "breed_descr")
                XCTAssert(data["date_of_birth"].string == _data["date_of_birth"] as? String, "date_of_birth")
                XCTAssert(data["weight"].double == _data["weight"] as? Double, "weight")
                XCTAssert(data["neutered"].bool == _data["neutered"] as? Bool, "neutered")
            }else{
                XCTFail()
            }
            
            if let id = data?["id"].int {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
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
        _data["type"] = "other"
        _data["type_descr"] = "Horse"
        _data["breed_descr"] = "Percheron"
        _data["date_of_birth"] = "2015-12-13"
        _data["weight"] = 5000.95
        _data["neutered"] = true
        
        APIManager.Instance.perform(call: .registerPet, with: _data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let data = data {
                XCTAssert(data["name"].string == _data["name"] as? String, "name")
                XCTAssert(data["type"].string == _data["type"] as? String, "type")
                XCTAssert(data["type_descr"].string == _data["type_descr"] as? String, "type_descr")
                XCTAssert(data["gender"].string == _data["gender"] as? String, "gender")
                XCTAssert(data["breed_descr"].string == _data["breed_descr"] as? String, "breed_descr")
                XCTAssert(data["date_of_birth"].string == _data["date_of_birth"] as? String, "date_of_birth")
                XCTAssert(data["weight"].double == _data["weight"] as? Double, "weight")
                XCTAssert(data["neutered"].bool == _data["neutered"] as? Bool, "neutered")
            }else{
                XCTFail()
            }
            
            if let id = data?["id"].int {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WrongBreed, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingPetName, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WeightOutOfRange, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- UnRegisterPet
    
    //    func testUnRegisterPetOk() {
    //
    //        let expect = expectation(description: "UnregisterPet")
    //
    //
    //        APIManager.Instance.perform(call: .unregisterPet, withKey: 54)  { (error, data) in
    //
    //            XCTAssertNil(error, "Error \(String(describing: error))")
    //            XCTAssertNotNil(data, "No data :(")
    //            expect.fulfill()
    //        }
    //
    //        waitForExpectations(timeout: 10) { error in
    //            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
    //        }
    //    }
    
    func testUnRegisterPetNotEnoughRights() {
        
        let expect = expectation(description: "UnregisterPet")
        
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: -1)  { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error?.errorCode))")
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
