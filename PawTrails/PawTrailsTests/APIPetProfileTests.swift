//
//  PetManagerTest.swift
//  PawTrails
//
//  Created by Marc Perello on 27/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class APIPetProfileTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let expect = expectation(description: "Example")
        APIAuthenticationTests().signIn { () in
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func getPets(_ callback: @escaping ((_ error: APIManagerError?, _ data:[String:Any]?)->())){
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            callback(error, data?.dictionaryObject)
        }
    }
    
    //MARK: EditPetProfile
    
    func testEditPetProfileCatOk() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        if let data = data?.dictionaryObject {
                            self.check(in: data, out: data)
                            expect.fulfill()
                        }
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileDogOneOk() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    // Dog with two breeds
                    
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        if let data = data?.dictionaryObject {
                            self.check(in: data, out: data)
                            expect.fulfill()
                        }
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileDogTwoOk() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    // Dog with two breeds
                    
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        if let data = data?.dictionaryObject {
                            self.check(in: data, out: data)
                            expect.fulfill()
                        }
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileOtherOk() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        if let data = data?.dictionaryObject {
                            self.check(in: data, out: data)
                            expect.fulfill()
                        }
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func check(in dataIn: [String:Any], out dataOut: [String:Any]){
        
        assert(dataIn["name"] as! String == dataOut["name"] as! String)
        assert(dataIn["type"] as! String == dataOut["type"] as! String)
        if dataIn["type_descr"] != nil && dataIn["type_descr"] as! String != "" {
            assert(dataIn["type_descr"] as! String == dataOut["type_descr"] as! String)
        }
        assert(dataIn["gender"] as! String == dataOut["gender"] as! String)
        if dataIn["breed"] != nil && dataIn["breed"] as! Int != 0 {
            assert(dataIn["breed"] as! Int == dataOut["breed"] as! Int)
        }
        if dataIn["breed1"] != nil && dataIn["breed1"] as! Int != 0 {
            assert(dataIn["breed1"] as! Int == dataOut["breed1"] as! Int)
        }
        if dataIn["breed_descr"] != nil && dataIn["breed_descr"] as! String != "" {
            assert(dataIn["breed_descr"] as! String == dataOut["breed_descr"] as! String)
        }
        assert(dataIn["date_of_birth"] as! String == dataOut["date_of_birth"] as! String)
        assert(dataIn["weight"] as! Double == dataOut["weight"] as! Double)
        assert(dataIn["neutered"] as! Bool == dataOut["neutered"] as! Bool)
    }

    func testEditPetProfileDateOfBirth() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileGenderFormat() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileWrongBreed() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.WrongBreed, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileMissingPetName() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    //                    data["name"] = "Paw"
                    data["type"] = "cat"
                    data["type_descr"] = ""
                    data["gender"] = "F"
                    data["breed"] = 204
                    data["breed1"] = 0
                    data["breed_descr"] = ""
                    data["date_of_birth"] = "2015-05-13"
                    data["weight"] = 2.3
                    data["neutered"] = false
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.MissingPetName, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileWeightOutOfRange() {
        
        let expect = expectation(description: "EditPetProfile")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.WeightOutOfRange, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditPetProfileNotFound() {
        
        let expect = expectation(description: "EditPetProfile")
        var data = [String:Any]()
        
        data["name"] = "Paw"

        APIManager.Instance.perform(call: .setPet, withKey: 0, with: data) { (error, data) in
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.NotFound, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    
    //MARK: ReadPetProfile
    
    func testGetPet() {
        
        let expect = expectation(description: "get pet")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    
                    
                    APIManager.Instance.perform(call: .getPet, withKey: petId) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    
    func testGetPets() {
        
        let expect = expectation(description: "get pets")
        
        getPets { (error, data) in

            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                for pet in pets {
                    print(pet)
                }
            }
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
}
