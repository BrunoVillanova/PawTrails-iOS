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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
