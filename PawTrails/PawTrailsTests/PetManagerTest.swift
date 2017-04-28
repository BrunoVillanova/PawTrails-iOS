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
        data["name"] = "pawy"
        data["type"] = "cat"
        data["gender"] = "F"
        data["breed"] = "204"
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutred"] = true
        
        APIManager.Instance.perform(call: .setPet, withKey: 2, with: data) { (error, data) in
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            expect.fulfill()
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
