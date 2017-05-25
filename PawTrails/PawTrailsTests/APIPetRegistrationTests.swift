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
    let takenDeviceCode = "niAy82KhGRdy"
    
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
    
    //MARK:- Check
    
    func testCheckDeviceOk() {
        
        let expect = expectation(description: "CheckDevice")
        
        APIManager.Instance.perform(call: .checkDevice, withKey: deviceCode) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssert(data?["available"] as! Bool , "Not Available")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCheckDeviceDeviceNotAvailable() {
        
        let expect = expectation(description: "CheckDevice")
        
        APIManager.Instance.perform(call: .checkDevice, withKey: takenDeviceCode) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssert(!(data?["available"] as! Bool), "Available")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- RegisterPet
    
    func testRegisterCatOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["name"] = "Paw"
        data["type"] = Type.cat.name.lowercased()
        data["gender"] = "U"
        data["breed"] = 204
        data["date_of_birth"] = "2015-12-13"
        data["weight"] = 5.128
        data["neutered"] = true
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let id = data?.tryCastInteger(for: "id") {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterDogOneOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["name"] = "Paw"
        data["type"] = "dog"
        data["type_descr"] = ""
        data["gender"] = "F"
        data["breed"] = 5
        data["breed_descr"] = ""
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutered"] = true
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let id = data?.tryCastInteger(for: "id") {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterDogTwoOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
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
        
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let id = data?.tryCastInteger(for: "id") {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRegisterOtherOk() {
        
        let expect = expectation(description: "RegisterPet")
        
        var data = [String:Any]()
        
        data["device_code"] = deviceCode
        data["name"] = "Paw"
        data["type"] = "other"
        data["type_descr"] = "Horse"
        data["breed_descr"] = "Percheron"
        data["date_of_birth"] = "2015-12-13"
        data["weight"] = 5000.95
        data["neutered"] = true
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            if let id = data?.tryCastInteger(for: "id") {
                
                self.remove(id, { (success) in
                    XCTAssert(success, "Success")
                    expect.fulfill()
                })
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WrongBreed, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingPetName, "Wrong Error \(String(describing: error?.errorCode))")
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
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WeightOutOfRange, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
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
//        waitForExpectations(timeout: 100) { error in
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
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func remove(_ petId: Int, _ callback: @escaping ((Bool)->())) {
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: petId)  { (error, data) in
            callback(error == nil)
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
