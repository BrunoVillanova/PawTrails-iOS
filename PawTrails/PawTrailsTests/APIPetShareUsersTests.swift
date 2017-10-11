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
        APIAuthenticationTests().signIn { () in
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func getPets(_ callback: @escaping ((_ error: APIManagerError?, _ data:[String:Any]?)->())){
        APIManager.instance.perform(call: .getPets) { (error, data) in
            callback(error, data?.dictionaryObject)
        }
    }
    
    func getSharedUsers(_ petId: Int, callback:@escaping (([[String:Any]]?)->())){
        
        APIManager.instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil, callback: { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let users = data?["users"].array {
                
                let shared = users.filter({ (user) -> Bool in
                    return (user["is_owner"].bool) == false
                }).map({ $0.dictionaryObject })
                callback(shared as? [[String : Any]])
            }else{
                callback(nil)
            }
        })
    }
    
    func getSharedUser(userEmail: String, _ petId: Int, callback:@escaping (([String:Any]?)->())){
        
        APIManager.instance.perform(call: .getSharedPetUsers, withKey: petId, with: nil, callback: { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let users = data?["users"].array {
                
                let shared = users.first(where: { (user) -> Bool in
                    return (user["email"].string) == userEmail
                })?.dictionaryObject
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
        
        APIManager.instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], callback: { (error, data) in
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        if let data = data {
                            XCTAssertNotNil(data["id"].string, "id")
                            XCTAssertNotNil(data["email"].string, "email")
                            XCTAssertNotNil(data["is_owner"].bool, "is_owner")
                        }else{
                            XCTFail()
                        }
                        
                        if let id = data?["id"].int {
                            self.remove(sharedUser: id, from: petId, callback: { (success) in
                                XCTAssert(success, "Not Removed")
                                expect.fulfill()
                            })
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?["id"].int {
                            
                            APIManager.instance.perform(call: .sharePet, withKey: petId, with: data?.dictionaryObject) { (error, data) in
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
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNotNil(error)
                        XCTAssert(error?.errorCode == ErrorCode.UserNotFound, "Wrong Error \(String(describing: error?.errorCode))")
                        expect.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testAddSharedNotEnoughRights() {
        let expect = expectation(description: "AddSharedUser")
        

        var data = [String:Any]()
        data["email"] = self.email
        
        APIManager.instance.perform(call: .sharePet, withKey: 0, with: data) { (error, data) in
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
    
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?["id"].int {
                            APIManager.instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], callback: { (error, data) in
                                assert(error == nil, "Error \(String(describing: error))")
                                assert(data != nil, "No Data returned")
                                expect.fulfill()
                            })
                        }
                        
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        if let id = data?["id"].int {
                            APIManager.instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":0], callback: { (error, data) in
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
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?["id"].int {
                            APIManager.instance.perform(call: .removeSharedPet, withKey: 0, with: ["user_id":id], callback: { (error, data) in
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
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
                    
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        assert(error == nil, "Error \(String(describing: error))")
                        assert(data != nil, "No Data returned")
                        
                        if let id = data?["id"].int {
                            APIManager.instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], callback: { (error, data) in
                                assert(error == nil, "Error \(String(describing: error))")
                                assert(data != nil, "No Data returned")
                                
                                APIManager.instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], callback: { (error, data) in
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
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
                    APIManager.instance.perform(call: .sharePet, withKey: petId, with: data) { (error, data) in
                        XCTAssertNil(error, "Error \(String(describing: error))")
                        XCTAssertNotNil(data, "No data :(")
                        
                        APIAuthenticationTests().signIn(email: self.email, password: ezdebug.password) { () in
                            
                            APIManager.instance.perform(call: .leaveSharedPet, withKey: petId, callback: { (error, data) in
                                
                                XCTAssertNil(error, "Error \(String(describing: error))")
                                XCTAssertNotNil(data, "No data :(")
                                expect.fulfill()
                            })
                        }
                    }
                }
            }
            
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testLeavePetNotEnoughRights() {
        
        let expect = expectation(description: "LeavePet")
        
        self.getPets { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            if let pets = data?["pets"] as? [[String:Any]] {
                
                if pets.count > 0, let petId = pets[0].tryCastInteger(for: "id") {
                    
                    APIAuthenticationTests().signIn(email: self.email, password: ezdebug.password) { () in
                        
                        APIManager.instance.perform(call: .leaveSharedPet, withKey: petId, with: nil, callback: { (error, data) in
                            
                            XCTAssertNotNil(error)
                            XCTAssert(error?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error?.errorCode))")
                            expect.fulfill()
                        })
                    }
                }
            }
            
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
        
}
