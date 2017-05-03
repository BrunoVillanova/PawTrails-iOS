//
//  PetManagerTest.swift
//  PawTrails
//
//  Created by Marc Perello on 27/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails


class PetManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
    func testRegisterPet() {
        
        let expect = expectation(description: "register pet")
        
        var data = [String:Any]()
        data["device_code"] = "yL4uGWmpqNiY"
        data["name"] = "pawy"
        data["type"] = "dog"
        data["gender"] = "M"
        data["breed"] = "9"
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutred"] = false
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            
            assert(error != nil, "Error \(String(describing: error))")
            assert(data == nil, "No Data returned")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testUnRegisterPet() {
        
        let expect = expectation(description: "register pet")
        
        var data = [String:Any]()
        data["device_code"] = "yL4uGWmpqNiY"
        data["name"] = "pawy"
        data["type"] = "dog"
        data["gender"] = "M"
        data["breed"] = "9"
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutred"] = false
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    
    
    
    func testGetPet() {
        
        let expect = expectation(description: "get pet")
        
        APIManager.Instance.perform(call: .getPet, withKey: 3) { (error, data) in
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testGetPets() {
        
        let expect = expectation(description: "get pets")
        
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                for pet in pets {
                    print(pet)
                }
            }
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testSetPet() {
        
        let expect = expectation(description: "set pet")
        
        var data = [String:Any]()
        
        // Dog with two breeds
        
//        data["name"] = "Paw"
//        data["type"] = "dog"
//        data["type_descr"] = ""
//        data["gender"] = "F"
//        data["breed"] = 5
//        data["breed1"] = 6
//        data["breed_descr"] = ""
//        data["date_of_birth"] = "2015-05-13"
//        data["weight"] = 2.3
//        data["neutered"] = true

//        data["name"] = "Paw"
//        data["type"] = "cat"
//        data["type_descr"] = ""
//        data["gender"] = "F"
//        data["breed"] = 204
//        data["breed1"] = 0
//        data["breed_descr"] = ""
//        data["date_of_birth"] = "2015-05-13"
//        data["weight"] = 2.3
//        data["neutered"] = false

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
        
        APIManager.Instance.perform(call: .setPet, withKey: 2, with: data) { (error, petData) in
            assert(error == nil, "Error \(String(describing: error))")
            assert(petData != nil, "No Data returned")
            
            if let petData = petData {
                assert(data["name"] as! String == petData["name"] as! String)
                assert(data["type"] as! String == petData["type"] as! String)
                if data["type_descr"] != nil && data["type_descr"] as! String != "" {
                    assert(data["type_descr"] as! String == petData["type_descr"] as! String)
                }
                assert(data["gender"] as! String == petData["gender"] as! String)
                if data["breed"] != nil && data["breed"] as! Int != 0 {
                    assert(data["breed"] as! Int == petData["breed"] as! Int)
                }
                if data["breed1"] != nil && data["breed1"] as! Int != 0 {
                    assert(data["breed1"] as! Int == petData["breed1"] as! Int)
                }
                if data["breed_descr"] != nil && data["breed_descr"] as! String != "" {
                    assert(data["breed_descr"] as! String == petData["breed_descr"] as! String)
                }
                assert(data["date_of_birth"] as! String == petData["date_of_birth"] as! String)
                assert(data["weight"] as! Double == petData["weight"] as! Double)
                assert(data["neutered"] as! Bool == petData["neutered"] as! Bool)
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
