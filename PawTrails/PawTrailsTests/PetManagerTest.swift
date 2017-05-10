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
    
    func registerPet(_ callback: @escaping ((_ error: APIManagerError?, _ data:[String:Any]?)->())){
        
        var data = [String:Any]()
        data["device_code"] = "6sIKscPaunaJ"
        data["name"] = "pawy"
        data["type"] = "dog"
        data["gender"] = "M"
        data["breed"] = "9"
        data["date_of_birth"] = "2015-05-13"
        data["weight"] = 2.3
        data["neutred"] = false
        
        APIManager.Instance.perform(call: .registerPet, with: data) { (error, data) in
            callback(error, data)
        }
    }
    
    func unRegisterPet(with id: String, _ callback: @escaping ((_ error: APIManagerError?, _ data:[String:Any]?)->())){
        
        APIManager.Instance.perform(call: .unregisterPet, withKey: id, with: nil, completition: { (error, data) in
            callback(error, data)
        })
    }
    
    
    func testRegisterAndUnRegisterPet() {
        
        let expect = expectation(description: "register pet")
        
        registerPet { (error, data) in
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")

            if let petId = data?["id"] as? String {
                
                self.unRegisterPet(with: petId, { (error, data) in
                    assert(error == nil, "Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    
    
    
    func testGetPet() {
        
        let expect = expectation(description: "get pet")
        
        registerPet { (error, data) in
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")

            if let petId = data?["id"] as? String {
                
                APIManager.Instance.perform(call: .getPet, withKey: petId) { (error, data) in
                    assert(error == nil, "Error \(String(describing: error))")
                    assert(data != nil, "No Data returned")
                    
                    self.unRegisterPet(with: petId, { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        expect.fulfill()
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func getPets(_ callback: @escaping ((_ error: APIManagerError?, _ data:[String:Any]?)->())){
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            callback(error, data)
        }
    }
    
    func testGetPets() {
        
        let expect = expectation(description: "get pets")
        
        getPets { (error, data) in

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
        
        getPets { (error, data) in
            
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0]["id"] as? String {
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
                    
                    APIManager.Instance.perform(call: .setPet, withKey: petId, with: data) { (error, petData) in
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
                    
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func getSharedUsers(_ petId: String, callback:@escaping (([[String:Any]]?)->())){
        
        APIManager.Instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil, completition: { (error, data) in
            
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            
            callback(data?["users"] as? [[String:Any]])

        })
    }
    
    func testShareUnsharePet() {
        
        let testUserEmail = "iosV4@test.com"
        
        let expect = expectation(description: "share pet")
        
        getPets { (error, data) in
            
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0]["id"] as? String {
                    
                    let data:[String:Any] = ["email":testUserEmail]
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data, completition: { (error, data) in
                        
                        assert(error == nil, "Error \(String(describing: error))")
                        
                        self.getSharedUsers(petId, callback: { (usersData) in
                            
                            if let usersData = usersData {
                                var found = false
                                for userData in usersData {
                                    if !found, let email = userData["email"] as? String {
                                        found = email == testUserEmail
                                        if found, let id = userData["id"] as? String {
                                            
                                            APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], completition: { (error, data) in
                                                
                                                assert(error == nil, "Error \(String(describing: error))")
                                                self.getSharedUsers(petId, callback: { (usersData) in
                                                    
                                                    if let usersData = usersData {
                                                        var found = false
                                                        for userData in usersData {
                                                            if !found, let email = userData["email"] as? String {
                                                                found = email == testUserEmail
                                                            }
                                                        }
                                                        assert(found == false, "ahà")
                                                        expect.fulfill()
                                                    }
                                                })
                                            })
                                        }
                                    }
                                }
                            }
                        })
                        
                    })
                    
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    fileprivate let testUserEmail = "ios2@test.com"

    
    func testSharePet() {
        
        
        let expect = expectation(description: "share pet")
        
        getPets { (error, data) in
            
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0]["id"] as? String {
                    
                    let data:[String:Any] = ["email":self.testUserEmail]
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data, completition: { (error, data) in
                        
                        assert(error == nil, "Error \(String(describing: error))")
                        
                        self.getSharedUsers(petId, callback: { (usersData) in
                            
                            if let usersData = usersData {
                                var found = false
                                for userData in usersData {
                                    if !found, let email = userData["email"] as? String {
                                        found = email == self.testUserEmail
                                    }
                                }
                                assert(found == true, "Not Added Properly")
                                expect.fulfill()

                            }
                        })
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testRemovePetUser() {
        
        let expect = expectation(description: "share pet")
        
        getPets { (error, data) in
            
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0]["id"] as? String {
                    
                    self.getSharedUsers(petId, callback: { (usersData) in
                        
                        if let usersData = usersData {
                            var found = false
                            for userData in usersData {
                                if !found, let email = userData["email"] as? String {
                                    found = email == self.testUserEmail
                                    if found, let id = userData["id"] as? String {
                                        
                                        APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], completition: { (error, data) in
                                            
                                            assert(error == nil, "Error \(String(describing: error))")
                                            self.getSharedUsers(petId, callback: { (usersData) in
                                                
                                                if let usersData = usersData {
                                                    var found = false
                                                    for userData in usersData {
                                                        if !found, let email = userData["email"] as? String {
                                                            found = email == self.testUserEmail
                                                        }
                                                    }
                                                    assert(found == false, "Not Removed")
                                                    expect.fulfill()
                                                }
                                            })
                                        })
                                    }
                                }
                            }
                        }
                    })
                    
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testLeavePetUser() {
        
        let expect = expectation(description: "share pet")

        self.getPets { (error, data) in
            
            assert(error == nil, "Error \(String(describing: error))")
            assert(data != nil, "No Data returned")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0]["id"] as? String {
                    
                    APIManagerTests().signIn(email: self.testUserEmail, password: ezdebug.password) { (id, token) in
                        
                        SharedPreferences.set(.id, with: id)
                        SharedPreferences.set(.token, with: token)
                        
                        APIManager.Instance.perform(call: .leaveSharedPet, withKey: petId, with: nil, completition: { (error, data) in
                            
                            assert(error == nil, "Error \(String(describing: error))")

                            APIManagerTests().signIn { (id, token) in
                                
                                SharedPreferences.set(.id, with: id)
                                SharedPreferences.set(.token, with: token)
                                
                                self.getSharedUsers(petId, callback: { (usersData) in
                                    
                                    if let usersData = usersData {
                                        var found = false
                                        for userData in usersData {
                                            if !found, let email = userData["email"] as? String {
                                                found = email == self.testUserEmail
                                            }
                                        }
//                                        assert(found == false, "Not Left")
                                        expect.fulfill()
                                    }
                                })
                            }
                                 
                        })
                    }
                }
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
