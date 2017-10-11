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
        APIAuthenticationTests().signIn { () in
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
        APIManager.instance.perform(call: .signIn, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error while getting User \(String(describing: error))")
            XCTAssertNotNil(data, "Data")
            XCTAssertNotNil(data?["user"], "User")
            
            let _user = User((data?["user"])!)
                
                DataManager.instance.set(_user, callback: { (error, user) in
                    XCTAssertNil(error, "Error while setting User \(String(describing: error.debugDescription))")
                    XCTAssertNotNil(user, "User")
                    if let user = user {
                        XCTAssert(user.id == _user.id)
                        XCTAssert(user.email == ezdebug.email)
                    }else{
                        XCTFail()
                    }
                    expect.fulfill()
                })
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetUserIdNotFound() {
        let expect = expectation(description: "Set User")
        
        let user = User()
        
        DataManager.instance.set(user, callback: { (error, user) in
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
        
        DataManager.instance.getUser { (error, user) in
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
        let id = SharedPreferences.get(.id)
        if id != "" {
            _ = SharedPreferences.remove(.id)
            DataManager.instance.getUser { (error, user) in
                
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
        
        let id = SharedPreferences.get(.id)
        if id != "" {
            SharedPreferences.set(.id, with: "-1")
            DataManager.instance.getUser { (error, user) in
                
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
        
        DataManager.instance.loadUser { (error, user) in
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
        let id = SharedPreferences.get(.id)
        if id != "" {
            _ = SharedPreferences.remove(.id)
            DataManager.instance.loadUser { (error, user) in
                
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
        
        let id = SharedPreferences.get(.id)
        if id != "" {
            SharedPreferences.set(.id, with: "0")
            DataManager.instance.loadUser { (error, user) in
                
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
        
        let data = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9) ?? Data()

        DataManager.instance.saveUser(image: data) { (error) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSetImagePathFormat() {
        
//        let expect = expectation(description: "SetImage")
//        
//        var data =  UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
//        
//        DataManager.instance.saveUser(image: data) { (error) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.PathFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    func testSetImageMissingUserId() {
//        
//        let expect = expectation(description: "SetImage")
//        
//        var data = [String:Any]()
//        data["path"] = "user"
//        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
//        
//        DataManager.instance.saveUser(image: data) { (error) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingUserId, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }

    func testSetImageOk2() {
        
        let expect = expectation(description: "SetImage")
        
        DataManager.instance.getPets { (error, pets) in
            
            if error == nil, let id = pets?.first?.id {
                
                let data =  UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9) ?? Data()
                
                DataManager.instance.savePet(image: data, into: id, callback: { (error) in
                    
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
        
//        let expect = expectation(description: "SetImage")
//        
//        var data = [String:Any]()
//        data["path"] = "pet"
//        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
//        
//        DataManager.instance.set(image: data) { (error) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPetId, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            expect.fulfill()
//        }
//        
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    func testSetImageMissingImageFile() {
        
//        let expect = expectation(description: "UploadImage")
//        
//        var data = [String:Any]()
//        data["path"] = "user"
//        data["userid"] = SharedPreferences.get(.id)
//        
//        DataManager.instance.set(image: data) { (error) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingImageFile, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    func testSetImageIncorrectImageMime() {
        
//        let expect = expectation(description: "SetImage")
//        
//        var data = [String:Any]()
//        data["path"] = "user"
//        data["userid"] = SharedPreferences.get(.id)
//        data["picture"] = UIImagePNGRepresentation(UIImage(named: "logo")!)
//        
//        DataManager.instance.set(image: data) { (error) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.IncorrectImageMime, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    func testSetImageImageFileSize() {
        
//        let expect = expectation(description: "SetImage")
//        
//        var data = [String:Any]()
//        data["path"] = "user"
//        data["userid"] = SharedPreferences.get(.id)
//        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "bigImage")!, 1.0)
//        
//        DataManager.instance.set(image: data) { (error) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.ImageFileSize, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    //MARK:- SaveUser
    
    func testSaveUserOk() {
        
        let expect = expectation(description: "SaveUser")
        
        let name = "John"
        let surname = "Smith"
        let gender = Gender.female
        let birthday = Date()
        let notification = true
        let phone = Phone(number: "123456789", countryCode: "34")
        let address = Address.init(city: "Cork", country: "Ireland", line0: "l0", line1: "l1", line2: "l2", postalCode: "58745", state: "Munster")
        
        let user = User.init(id: 0, email: nil, name: name, surname: surname, birthday: birthday, gender: gender, image: nil, imageURL: nil, notification: notification, address: address, phone: phone, friends: nil)
        
        DataManager.instance.save(user) { (error, user) in

            XCTAssertNil(error, "Error setting profile \(String(describing: error))")
            XCTAssertNotNil(user)
            
            
            if let user = user {
                XCTAssert(user.name == name)
                XCTAssert(user.surname == surname)
                XCTAssert(user.gender == gender)
                XCTAssert(user.birthday?.toStringShow == birthday.toStringShow)
                XCTAssert(user.notification == notification)
                
                if let phone = user.phone {
                    XCTAssert(phone.number == phone.number)
                    XCTAssert(phone.countryCode == phone.countryCode)
                }else{
                    XCTFail()
                }
                
                if let address = user.address {
                    XCTAssert(address.line0 == address.line0)
                    XCTAssert(address.line1 == address.line1)
                    XCTAssert(address.line2 == address.line2)
                    XCTAssert(address.city == address.city)
                    XCTAssert(address.postalCode == address.postalCode)
                    XCTAssert(address.state == address.state)
                    XCTAssert(address.country == address.country)
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
        
//        let expect = expectation(description: "SaveUser")
//        
//        
//        var userData = [String:Any]()
//        userData["date_of_birth"] = "1992/15/25"
//        
//        DataManager.instance.save(user: userData) { (error, user) in
//            
//            XCTAssertNil(user)
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    func testSaveUserGenderFormat() {
        
//        let expect = expectation(description: "SaveUser")
//        
//        
//        var userData = [String:Any]()
//        userData["gender"] = "HOLA"
//        
//        
//        DataManager.instance.save(user: userData) { (error, user) in
//            
//            XCTAssertNil(user)
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    func testSaveUserPhoneFormat() {
        
//        let expect = expectation(description: "editUserProfile")
//        
//        let phone = [
//            "number": "123456789",
//            "country_code":"AHH"
//        ]
//        
//        
//        var userData = [String:Any]()
//        userData["mobile"] = phone
//        
//        DataManager.instance.save(user: userData) { (error, user) in
//            
//            XCTAssertNil(user)
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.PhoneFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            
//            expect.fulfill()
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
    }
    
    //MARK:- RemoveUser
    
    func testRemoveUserOk() {
        
        let expect = expectation(description: "RemoveUser")
        
        if DataManager.instance.removeUser() {
            DataManager.instance.getUser(callback: { (error, user) in
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
        let id = SharedPreferences.get(.id)
        if id != "" {
            _ = SharedPreferences.remove(.id)
            
            if !DataManager.instance.removeUser() {
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
        
        let id = SharedPreferences.get(.id)
        if id != "" {
            SharedPreferences.set(.id, with: "-1")
            
            if !DataManager.instance.removeUser() {
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
        
        DataManager.instance.loadPetFriends { (error, friends) in
            
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
        
        let token = SharedPreferences.get(.token)
        if token != "" {
            _ = SharedPreferences.remove(.token)
            
            DataManager.instance.loadPetFriends { (error, friends) in
                
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
        
        let id = SharedPreferences.get(.id)
        if id != "" {
            _ = SharedPreferences.remove(.id)
            
            DataManager.instance.loadPetFriends { (error, friends) in
                
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
        
        let id = SharedPreferences.get(.id)
        if id != "" {
            SharedPreferences.set(.id, with: "-1")
            
            DataManager.instance.loadPetFriends { (error, friends) in
                
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
