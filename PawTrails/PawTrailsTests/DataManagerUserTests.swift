//
//  AuthManagerTests.swift
//  PawTrails
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class DataManagerUserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
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
    
    //MARK:- SetUser
    
    func testSetUserOk() {
        let expect = expectation(description: "Set User")
        
        let data = ["email":ezdebug.email, "password":ezdebug.password, "is4test":ezdebug.is4test]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error while getting User \(String(describing: error))")
            XCTAssertNotNil(data, "Data")
            XCTAssertNotNil(data?["user"], "User")
            
            if let userData = data?["user"] as? [String:Any] {
                
                DataManager.Instance.setUser(userData, callback: { (error, user) in
                    XCTAssertNil(error, "Error while setting User \(String(describing: error.debugDescription))")
                    XCTAssertNotNil(user, "User")
                    if let user = user {
                        XCTAssert(Int(user.id) == userData.tryCastInteger(for: "id"))
                        XCTAssert(user.email == ezdebug.email)
                    }else{
                        XCTFail()
                    }
                    expect.fulfill()
                })
            }else{
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetUserIdNotFound() {
        let expect = expectation(description: "Set User")
        
        let userData = [String:Any]()
        
        DataManager.Instance.setUser(userData, callback: { (error, user) in
            XCTAssertNotNil(error, "Error while setting User \(String(describing: error.debugDescription))")
            XCTAssertNil(user, "User")
            if let error = error {
                XCTAssert(error.responseError == ResponseError.IdNotFound)
            }else{
                XCTFail()
            }
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- GetUser
    
    func testGetUserOk() {
        let expect = expectation(description: "GetUser")
        
        DataManager.Instance.getUser { (error, user) in
            XCTAssertNil(error)
            XCTAssertNotNil(user)
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testGetUserIdNotFound() {
        let expect = expectation(description: "GetUser")
        
        if let id = SharedPreferences.get(.id) {
            _ = SharedPreferences.remove(.id)
            DataManager.Instance.getUser { (error, user) in
                
                XCTAssertNil(user)
                XCTAssertNotNil(error)
                XCTAssert(error?.DBError == DatabaseError.IdNotFound)
                SharedPreferences.set(.id, with: id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testGetUserNotFound() {
        let expect = expectation(description: "GetUser")
        
        if let id = SharedPreferences.get(.id) {
            SharedPreferences.set(.id, with: "-1")
            DataManager.Instance.getUser { (error, user) in
                
                XCTAssertNil(user)
                XCTAssertNotNil(error)
                XCTAssert(error?.DBError == DatabaseError.NotFound)
                SharedPreferences.set(.id, with: id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- LoadUser

    func testLoadUserOk() {
        let expect = expectation(description: "LoadUser")
        
        DataManager.Instance.loadUser { (error, user) in
            XCTAssertNil(error)
            XCTAssertNotNil(user)
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadUserIdNotFound() {
        let expect = expectation(description: "LoadUser")
        
        if let id = SharedPreferences.get(.id) {
            _ = SharedPreferences.remove(.id)
            DataManager.Instance.loadUser { (error, user) in
                
                XCTAssertNil(user)
                XCTAssertNotNil(error)
                XCTAssert(error?.DBError == DatabaseError.IdNotFound)
                SharedPreferences.set(.id, with: id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
        
    }
    
    func testLoadUserAnauthorized() {
        let expect = expectation(description: "LoadUser")
        
        if let id = SharedPreferences.get(.id) {
            SharedPreferences.set(.id, with: "0")
            DataManager.Instance.loadUser { (error, user) in
                
                XCTAssertNil(user)
                XCTAssertNotNil(error)
                XCTAssert(error?.APIError?.errorCode == ErrorCode.Unauthorized, String.init(describing: error?.APIError.debugDescription))
                SharedPreferences.set(.id, with: id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
        
    }
    
    //MARK:- SetImage
    
    func testSetImageOk() {
        
        let expect = expectation(description: "SetImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)

        DataManager.Instance.set(image: data) { (error) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetImagePathFormat() {
        
        let expect = expectation(description: "SetImage")
        
        var data = [String:Any]()
        data["path"] = ""
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
        
        DataManager.Instance.set(image: data) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.PathFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetImageMissingUserId() {
        
        let expect = expectation(description: "SetImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
        
        DataManager.Instance.set(image: data) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingUserId, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }

    func testSetImageOk2() {
        
        let expect = expectation(description: "SetImage")
        
        PetManager.get { (error, pets) in
            
            if error == nil, let pets = pets {
                
                var data = [String:Any]()
                data["path"] = "pet"
                data["petid"] = pets.first(where: {$0.isOwner == true})?.id ?? -1
                data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
                
                DataManager.Instance.set(image: data, callback: { (error) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetImageMissingPetId() {
        
        let expect = expectation(description: "SetImage")
        
        var data = [String:Any]()
        data["path"] = "pet"
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
        
        DataManager.Instance.set(image: data) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPetId, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetImageMissingImageFile() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        
        DataManager.Instance.set(image: data) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingImageFile, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetImageIncorrectImageMime() {
        
        let expect = expectation(description: "SetImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImagePNGRepresentation(UIImage(named: "logo")!)
        
        DataManager.Instance.set(image: data) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.IncorrectImageMime, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetImageImageFileSize() {
        
        let expect = expectation(description: "SetImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "bigImage")!, 1.0)
        
        DataManager.Instance.set(image: data) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.ImageFileSize, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- SaveUser
    
    func testSaveUserOk() {
        
        let expect = expectation(description: "SaveUser")
        
        let name = "John"
        let surname = "Smith"
        let gender = Gender.female
        let birthday = Date()
        let notification = true
        let phoneData = [
            "number": "123456789",
            "country_code":"34"
        ]
        let addressData = [
            "line0": "l1",
            "line1": "l2",
            "line2": "l2",
            "city": "Cork",
            "postal_code": "58745",
            "state": "Munster",
            "country":"IE"
        ]
        
        
        var userData = [String:Any]()
        userData["id"] = SharedPreferences.get(.id) ?? -1
        userData["name"] = name
        userData["surname"] = surname
        userData["gender"] = gender.code
        userData["date_of_birth"] = birthday.toStringServer
        userData["notification"] = notification
        userData["mobile"] = phoneData
        userData["address"] = addressData
        
        DataManager.Instance.save(user: userData) { (error, user) in

            XCTAssertNil(error, "Error setting profile \(String(describing: error))")
            XCTAssertNotNil(user)
            
            
            if let user = user {
                XCTAssert(user.name == name)
                XCTAssert(user.surname == surname)
                XCTAssert(user.gender == gender.rawValue)
                XCTAssert(user.birthday?.toStringShow == birthday.toStringShow)
                XCTAssert(user.notification == notification)
                
                if let phone = user.phone {
                    XCTAssert(phone.number == phoneData["number"])
                    XCTAssert(phone.country_code == phoneData["country_code"])
                }else{
                    XCTFail()
                }
                
                if let address = user.address {
                    XCTAssert(address.line0 == addressData["line0"])
                    XCTAssert(address.line1 == addressData["line1"])
                    XCTAssert(address.line2 == addressData["line2"])
                    XCTAssert(address.city == addressData["city"])
                    XCTAssert(address.postal_code == addressData["postal_code"])
                    XCTAssert(address.state == addressData["state"])
                    XCTAssert(address.country == addressData["country"])
                }else{
                    XCTFail()
                }
            }else{
                XCTFail()
            }
            expect.fulfill()
            
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSaveUserDateOfBirth() {
        
        let expect = expectation(description: "SaveUser")
        
        
        var userData = [String:Any]()
        userData["date_of_birth"] = "1992/15/25"
        
        DataManager.Instance.save(user: userData) { (error, user) in
            
            XCTAssertNil(user)
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSaveUserGenderFormat() {
        
        let expect = expectation(description: "SaveUser")
        
        
        var userData = [String:Any]()
        userData["gender"] = "HOLA"
        
        
        DataManager.Instance.save(user: userData) { (error, user) in
            
            XCTAssertNil(user)
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSaveUserPhoneFormat() {
        
        let expect = expectation(description: "editUserProfile")
        
        let phone = [
            "number": "123456789",
            "country_code":"AHH"
        ]
        
        
        var userData = [String:Any]()
        userData["mobile"] = phone
        
        DataManager.Instance.save(user: userData) { (error, user) in
            
            XCTAssertNil(user)
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.PhoneFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- RemoveUser
    
    func testRemoveUserOk() {
        
        let expect = expectation(description: "RemoveUser")
        
        if DataManager.Instance.removeUser() {
            DataManager.Instance.getUser(callback: { (error, user) in
                XCTAssertNil(user)
                XCTAssertNotNil(error)
                XCTAssert(error?.DBError == DatabaseError.NotFound)
                expect.fulfill()
            })
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRemoveUserNoAuthenticated() {
        
        let expect = expectation(description: "RemoveUser")
        
        if let id = SharedPreferences.get(.id) {
            _ = SharedPreferences.remove(.id)
            
            if !DataManager.Instance.removeUser() {
                SharedPreferences.set(.id, with: id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testRemoveUserNoFound() {
        
        let expect = expectation(description: "RemoveUser")
        
        if let id = SharedPreferences.get(.id) {
            SharedPreferences.set(.id, with: "-1")
            
            if !DataManager.Instance.removeUser() {
                SharedPreferences.set(.id, with: id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- LoadUserFriends
    
    func testLoadUserFriendsOk() {
        
        let expect = expectation(description: "LoadUserFriends")
        
        DataManager.Instance.loadUserFriends { (error, friends) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(friends)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadUserFriendsUnauthorized() {
        
        let expect = expectation(description: "LoadUserFriends")
        if let token = SharedPreferences.get(.token) {
            _ = SharedPreferences.remove(.token)
            
            DataManager.Instance.loadUserFriends { (error, friends) in
                
                XCTAssertNil(friends)
                XCTAssertNotNil(error)
                XCTAssert(error?.APIError?.errorCode == ErrorCode.Unauthorized, "Error \(String(describing: error))")
                SharedPreferences.set(.token, with: token)
                
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadUserFriendsIdNotFound() {
        
        let expect = expectation(description: "LoadUserFriends")
        if let id = SharedPreferences.get(.id) {
            _ = SharedPreferences.remove(.id)
            
            DataManager.Instance.loadUserFriends { (error, friends) in
                
                XCTAssertNil(friends)
                XCTAssertNotNil(error)
                XCTAssert(error?.DBError == DatabaseError.IdNotFound, "Error \(String(describing: error))")
                SharedPreferences.set(.id, with: id)
                
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testLoadUserFriendsNotFound() {
        
        let expect = expectation(description: "LoadUserFriends")
        if let id = SharedPreferences.get(.id) {
            SharedPreferences.set(.id, with: "-1")
            
            DataManager.Instance.loadUserFriends { (error, friends) in
                
                XCTAssertNil(friends)
                XCTAssertNotNil(error)
                XCTAssert(error?.DBError == DatabaseError.NotFound, "Error \(String(describing: error))")
                SharedPreferences.set(.id, with: id)
                
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
