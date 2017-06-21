//
//  DataManagerPetSharingTests.swift
//  PawTrails
//
//  Created by Marc Perello on 06/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class DataManagerPetSharingTests: XCTestCase {
    
    let email = "ios2@test.com"
   
    override func setUp() {
        let expect = expectation(description: "Example")
        APIAuthenticationTests().signIn { (id, token) in
            SharedPreferences.set(.id, with: id)
            SharedPreferences.set(.token, with: token)
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- LoadPetFriends
    
    func testLoadPetFriendsOk() {
        
        let expect = expectation(description: "LoadPetFriends")
        
        DataManager.Instance.loadPetFriends { (error, petusers) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(petusers)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testLoadPetFriendsAnauthorized() {
        
        let expect = expectation(description: "LoadPetFriends")
        
        if let token = SharedPreferences.get(.token) {
            
            _ = SharedPreferences.remove(.token)
            DataManager.Instance.loadPetFriends { (error, petusers) in
                
                XCTAssertNil(petusers)
                XCTAssertNotNil(error, "Error \(String(describing: error))")
                XCTAssert(error?.APIError?.errorCode == ErrorCode.Unauthorized, "Error \(String(describing: error))")
                SharedPreferences.set(.token, with: token)
                expect.fulfill()
            }
            
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- GetPetFriends
    
    func testGetPetFriendsOk() {
        
        let expect = expectation(description: "GetPetFriends")
        
//        DataManager.Instance.getPetFriends(for: <#Pet#>, callback: { (error, petusers) in
//            
//            XCTAssertNil(error, "Error \(String(describing: error))")
//            XCTAssertNotNil(petusers)
            expect.fulfill()
//        })
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testGetPetFriendsNotFound() {
        
        let expect = expectation(description: "GetPetFriends")
        
        UserManager.get { (error, user) in
            if let user = user {
                
                let friends = user.mutableSetValue(forKey: "friends")
                friends.removeAllObjects()
                user.setValue(friends, forKey: "friends")
                
//                DataManager.Instance.getPetFriends(for: <#Pet#>, callback: { (error, petusers) in
//                    
//                    XCTAssertNil(petusers)
//                    XCTAssertNotNil(error, "Error \(String(describing: error))")
//                    XCTAssert(error?.DBError == DatabaseError.NotFound, "Error \(String(describing: error))")
                    expect.fulfill()
//                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- LoadSharedPetUsers
    
    func testLoadSharedPetUsersOk() {
        let expect = expectation(description: "LoadSharedPetUsers")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNotNil(pets)
            XCTAssertNil(error)
            
            if let petId = pets?.first(where: {$0.isOwner})?.id {
                
                DataManager.Instance.loadSharedPetUsers(for: petId, callback: { (error, petusers) in
                    XCTAssertNil(error)
                    XCTAssertNotNil(petusers)
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadSharedNotEnoughRights() {
        let expect = expectation(description: "LoadSharedPetUsers")
        
        DataManager.Instance.loadSharedPetUsers(for: 0, callback: { (error, petusers) in
            XCTAssertNil(petusers)
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, String(describing: error))
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- AddSharedUser
    
    func remove(sharedUser id: Int16, from petId: Int16, callback: @escaping ((Bool)->())) {
        
        APIManager.Instance.perform(call: .removeSharedPet, withKey: petId, with: ["user_id":id], completition: { (error, data) in
            callback(error == nil)
        })
    }
    
    func testAddSharedUserOk() {
        let expect = expectation(description: "AddSharedUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                
                data["email"] = self.email
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(users)
                    
                    if let id = users?.first(where: { $0.email == self.email })?.id {
                        self.remove(sharedUser: id, from: petId, callback: { (success) in
                            XCTAssert(success, "Not Removed")
                            expect.fulfill()
                        })
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }

    func testAddSharedUserAlreadyShared() {
        let expect = expectation(description: "AddSharedUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                
                data["email"] = self.email
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(users)
                    
                    if let id = users?.first(where: { $0.email == self.email })?.id {
                        DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                            XCTAssertNotNil(error)
                            XCTAssert(error?.APIError?.errorCode == ErrorCode.AlreadyShared, "Wrong Error \(String(describing: error))")
                            XCTAssertNil(users)
                            
                                self.remove(sharedUser: id, from: petId, callback: { (success) in
                                    XCTAssert(success, "Not Removed")
                                    expect.fulfill()
                                })
                        })
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSharedUserMissingEmail() {
        let expect = expectation(description: "AddSharedUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                
                data["email"] = ""
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error))")
                    XCTAssertNil(users)
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testAddSharedUserEmailFormat() {
        let expect = expectation(description: "AddSharedUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                
                data["email"] = "hello"
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error))")
                    XCTAssertNil(users)
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testAddSharedUserNotFound() {
        let expect = expectation(description: "AddSharedUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                
                data["email"] = "hello@try.com"
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.UserNotFound, "Wrong Error \(String(describing: error))")
                    XCTAssertNil(users)
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testAddSharedNotEnoughRights() {
        let expect = expectation(description: "AddSharedUser")
        
        
        var data = [String:Any]()
        
        data["email"] = self.email
        
        DataManager.Instance.addSharedUser(by: data, to: 0, callback: { (error, users) in
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error))")
            XCTAssertNil(users)
            expect.fulfill()
        })
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- RemoveSharedPet
 
    func testRemoveUserOk() {
        let expect = expectation(description: "RemoveUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                data["email"] = self.email
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in

                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(users)
                    
                    if let id = users?.first(where: {$0.email == self.email})?.id {
                        var data = [String:Any]()
                        data["user_id"] = id
                        DataManager.Instance.removeSharedUser(by: data, to: petId, callback: { (error) in
                            XCTAssertNil(error, "Error \(String(describing: error))")
                            expect.fulfill()
                        })
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
   
    func testRemoveUserUserNotFound() {
        let expect = expectation(description: "RemoveUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                data["email"] = self.email
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(users)
                    
                    if let id = users?.first(where: {$0.email == self.email})?.id {
                        var data = [String:Any]()
                        data["user_id"] = 0
                        DataManager.Instance.removeSharedUser(by: data, to: petId, callback: { (error) in
                            XCTAssertNotNil(error, "Error \(String(describing: error))")
                            XCTAssert(error?.APIError?.errorCode == ErrorCode.UserNotFound, "Error \(String(describing: error))")
                            
                            var data = [String:Any]()
                            data["user_id"] = id
                            DataManager.Instance.removeSharedUser(by: data, to: petId, callback: { (error) in
                                XCTAssertNil(error, "Error \(String(describing: error))")
                                expect.fulfill()
                            })
                        })
                    }
                })
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testRemoveUserNotEnoughRights() {
        let expect = expectation(description: "RemoveUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                data["email"] = self.email
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(users)
                    
                    if let id = users?.first(where: {$0.email == self.email})?.id {
                        var data = [String:Any]()
                        data["user_id"] = id
                        DataManager.Instance.removeSharedUser(by: data, to: 0, callback: { (error) in
                            XCTAssertNotNil(error, "Error \(String(describing: error))")
                            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, "Error \(String(describing: error))")
                            
                            var data = [String:Any]()
                            data["user_id"] = id
                            DataManager.Instance.removeSharedUser(by: data, to: petId, callback: { (error) in
                                XCTAssertNil(error, "Error \(String(describing: error))")
                                expect.fulfill()
                            })
                        })
                    }
                })
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }

    func testRemoveUserMissingRelationUserPet() {
        let expect = expectation(description: "RemoveUser")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                data["email"] = self.email
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(users)
                    
                    if let id = users?.first(where: {$0.email == self.email})?.id {
                        var data = [String:Any]()
                        data["user_id"] = id
                        DataManager.Instance.removeSharedUser(by: data, to: petId, callback: { (error) in
                            XCTAssertNil(error, "Error \(String(describing: error))")
                            var data = [String:Any]()
                            data["user_id"] = id
                            DataManager.Instance.removeSharedUser(by: data, to: petId, callback: { (error) in
                                XCTAssertNotNil(error, "Error \(String(describing: error))")
                                XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingRelationUserPet, "Error \(String(describing: error))")
                                expect.fulfill()
                            })
                        })
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- LeavePet
    
    func testLeavePetOk() {
        
        let expect = expectation(description: "LeavePet")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                data["email"] = self.email
                
                DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(users)
                    
                    APIAuthenticationTests().signIn(email: self.email, password: ezdebug.password) { (id, token) in
                        
                        SharedPreferences.set(.id, with: id)
                        SharedPreferences.set(.token, with: token)
                        
                        DataManager.Instance.leaveSharedPet(by: petId, callback: { (error) in
                            
                            XCTAssertNil(error, "Error \(String(describing: error))")
                            expect.fulfill()
                        })
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testLeavePetNotEnoughRights() {
        
        let expect = expectation(description: "LeavePet")
        
        DataManager.Instance.getPets { (error, pets) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(pets)
            
            if let petId = pets?.first(where: { $0.isOwner })?.id {
                var data = [String:Any]()
                data["email"] = self.email
                
                
                APIAuthenticationTests().signIn(email: self.email, password: ezdebug.password) { (id, token) in
                    
                    SharedPreferences.set(.id, with: id)
                    SharedPreferences.set(.token, with: token)
                    
                    DataManager.Instance.leaveSharedPet(by: petId, callback: { (error) in
                        
                        XCTAssertNotNil(error)
                        XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error))")
                        expect.fulfill()
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
}
