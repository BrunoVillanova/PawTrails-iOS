//
//  APITablesTest.swift
//  PawTrails
//
//  Created by Marc Perello on 24/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class APITablesTests: XCTestCase {
    
    override func setUp() {
        let expect = expectation(description: "Example")
        APIAuthenticationTests().signIn { () in
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testPetClassesOk() {
        
        let expect = expectation(description: "PetClasses")
        
        APIManager.instance.perform(call: .getPetClasses) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssertNotNil(data?["classes"], "No Tables")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testPetBreedsCatOk() {
        let expect = expectation(description: "Breeds")
        
        let type = Type.cat
        
        APIManager.instance.perform(call: .getBreeds, withKey: type.code) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssertNotNil(data?["breeds"], "No Tables")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testPetBreedsDogOk() {
        let expect = expectation(description: "Breeds")
        
        let type = Type.dog
        
        APIManager.instance.perform(call: .getBreeds, withKey: type.code) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssertNotNil(data?["breeds"], "No Tables")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testPetBreedsError() {
        let expect = expectation(description: "Breeds")
        
        APIManager.instance.perform(call: .getBreeds, withKey: "") { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.NotFound, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testCountriesOk() {
        
        let expect = expectation(description: "Countries")
        
        APIManager.instance.perform(call: .getCountries) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssertNotNil(data?["countries"], "No Tables")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testContinentsOk() {
        
        let expect = expectation(description: "Continents")
        
        APIManager.instance.perform(call: .getContinents) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssertNotNil(data?["continents"], "No Tables")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
}
