//
//  APIPetShareUsersTests.swift
//  PawTrails
//
//  Created by Marc Perello on 24/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class APIPetShareUsersTests: XCTestCase {
    
    let email = "ios2@test.com"
    
    override func setUp() {
        super.setUp()
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
    
    func getPets(_ callback: @escaping ((_ error: APIManagerError?, _ data:[String:Any]?)->())){
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            callback(error, data)
        }
    }
    
    func getSharedUsers(_ petId: Int, callback:@escaping (([[String:Any]]?)->())){
        
        APIManager.Instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil, completition: { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let users = data?["users"] as? [[String:Any]] {
                
                let shared = users.filter({ (user) -> Bool in
                    return (user["is_owner"] as? Bool) == false
                })
                callback(shared)
            }else{
                callback(nil)
            }
        })
    }
    
    func getSharedUser(userEmail: String, _ petId: Int, callback:@escaping (([String:Any]?)->())){
        
        APIManager.Instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil, completition: { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let users = data?["users"] as? [[String:Any]] {
                
                let shared = users.first(where: { (user) -> Bool in
                    return (user["email"] as? String) == userEmail
                })
                callback(shared)
            }else{
                callback(nil)
            }
        })
    }
    
    func contains(sharedUser: String, into petId: Int, callback: @escaping ((Bool)->())) {
        
        getSharedUsers(petId) { (users) in
            if let users = users {
                for user in users {
                    
                    if let email = user["email"] as? String {
                        if email == sharedUser {
                            callback(true)
                            return
                        }
                    }
                    
                }
            }
            callback(false)
        }
    }
    
    func remove(sharedUser id: Int, from petId: Int, callback: @escaping ((Bool)->())) {
        
        APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], completition: { (error, data) in
            callback(error == nil)
        })
    }
    
    //MARK:- AddSharedUser
    
    func testAddSharedUserOk() {
        let expect = expectation(description: "AddSharedUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = self.email
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        if let data = data {
                            XCTAssertNotNil(data["id"] as? String, "id")
                            XCTAssertNotNil(data["email"] as? String, "email")
                            XCTAssertNotNil(data["is_owner"] as? Bool, "is_owner")
                        }else{
                            XCTFail()
                        }
                        
                        if let id = data?.tryCastInteger(for: "id") {
                            self.remove(sharedUser: id, from: petId, callback: { (success) in
                                XCTAssert(success, "Not Removed")
                                
                                expect.fulfill()
                            })
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSharedUserAlreadyShared() {
        let expect = expectation(description: "AddSharedUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = self.email
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?.tryCastInteger(for: "id") {
                            
                            APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                                XCTAssertNotNil(error)
                                XCTAssert(error?.errorCode == ErrorCode.AlreadyShared, "Wrong Error \(String(describing: error?.errorCode))")
                                self.remove(sharedUser: id, from: petId, callback: { (success) in
                                    XCTAssert(success, "Not Removed")
                                    
                                    expect.fulfill()
                                })
                                
                            }
                        }
                        
                        
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSharedUserMissingEmail() {
        let expect = expectation(description: "AddSharedUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = ""
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testAddSharedUserEmailFormat() {
        let expect = expectation(description: "AddSharedUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = "hello"
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testAddSharedUserNotFound() {
        let expect = expectation(description: "AddSharedUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = "hello@try.com"
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.UserNotFound, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testAddSharedNotEnoughRights() {
        let expect = expectation(description: "AddSharedUser")
        

        var data = [String:Any]()
        data["email"] = self.email
        
        APIManager.Instance.perform(call: .sharePet, withKey: 0, with: data) { (error, data) in
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
    
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- Remove User Shared
    
    func testRemoveUserOk() {
        let expect = expectation(description: "RemoveUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = self.email
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?.tryCastInteger(for: "id") {
                            APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], completition: { (error, data) in
                                assert(error == nil, "Error \(String(describing: error))")
                                assert(data != nil, "No Data returned")
                                expect.fulfill()
                            })
                        }
                        
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testRemoveUserUserNotFound() {
        let expect = expectation(description: "RemoveUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = self.email
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        if let id = data?.tryCastInteger(for: "id") {
                            APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":0], completition: { (error, data) in
                                XCTAssertNotNil(error)
                                XCTAssert(error?.errorCode == ErrorCode.UserNotFound, "Wrong Error \(String(describing: error?.errorCode))")
                                self.remove(sharedUser: id, from: petId, callback: { (success) in
                                    XCTAssert(success, "Not Removed")
                                    
                                    expect.fulfill()
                                })
                            })
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testRemoveUserNotEnoughRights() {
        let expect = expectation(description: "RemoveUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = self.email
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?.tryCastInteger(for: "id") {
                            APIManager.Instance.perform(call: .removeSharedPet, withKey: 0, with: ["user_id":id], completition: { (error, data) in
                                XCTAssertNotNil(error)
                                XCTAssert(error?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error?.errorCode))")
                                
                                self.remove(sharedUser: id, from: petId, callback: { (success) in
                                    XCTAssert(success, "Not Removed")
                                    
                                    expect.fulfill()
                                })
                                
                            })
                        }
                        
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testRemoveUserMissingRelationUserPet() {
        let expect = expectation(description: "RemoveUser")
        
        getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    
                    data["email"] = self.email
                    
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?.tryCastInteger(for: "id") {
                            APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], completition: { (error, data) in
                                assert(error == nil, "Error \(String(describing: error))")
                                assert(data != nil, "No Data returned")
                                
                                APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], completition: { (error, data) in
                                    XCTAssertNotNil(error)
                                    XCTAssert(error?.errorCode == ErrorCode.MissingRelationUserPet, "Wrong Error \(String(describing: error?.errorCode))")
                                    expect.fulfill()
                                })
                            })
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- Leave Pet

    func testLeavePetOk() {
        
        let expect = expectation(description: "LeavePet")
        
        self.getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    var data = [String:Any]()
                    data["email"] = self.email
                    APIManager.Instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        APIAuthenticationTests().signIn(email: self.email, password: ezdebug.password) { (id, token) in
                            
                            SharedPreferences.set(.id, with: id)
                            SharedPreferences.set(.token, with: token)
                            
                            APIManager.Instance.perform(call: .leaveSharedPet, withKey: petId, completition: { (error, data) in
                                
                                XCTAssertNil(error, "Error \(String(describing: error))")
                                XCTAssertNotNil(data, "No data :(")
                                expect.fulfill()
                            })
                        }
                    }
                }
            }
            
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testLeavePetNotEnoughRights() {
        
        let expect = expectation(description: "LeavePet")
        
        self.getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    
                    APIAuthenticationTests().signIn(email: self.email, password: ezdebug.password) { (id, token) in
                        
                        SharedPreferences.set(.id, with: id)
                        SharedPreferences.set(.token, with: token)
                        
                        APIManager.Instance.perform(call: .leaveSharedPet, withKey: petId, with: nil, completition: { (error, data) in
                            
                            XCTAssertNotNil(error)
                            XCTAssert(error?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error?.errorCode))")
                            expect.fulfill()
                        })
                    }
                }
            }
            
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
        
}
