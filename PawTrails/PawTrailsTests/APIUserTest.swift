//
//  APIUserTest.swift
//  PawTrails
//
//  Created by Marc Perello on 23/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class APIUserTest: XCTestCase {
    
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
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK:- EditProfile
    
    func testEditUserProfileOk() {
        
        let expect = expectation(description: "editUserProfile")
        
        let name = "John"
        let surname = "Smith"
        let gender = Gender.female
        let birthday = Date()
        let notification = true
        let phone = [
            "number": "123456789",
            "country_code":"34"
        ]
        let address = [
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
        userData["mobile"] = phone
        userData["address"] = address
        
        
        APIManager.Instance.perform(call: .setUser, with: userData) { (error, data) in
            
            XCTAssertNil(error, "Error setting profile \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")

            
            if let data = data {
                XCTAssert(data["name"] as? String == name, "Name")
                XCTAssert(data["surname"] as? String == surname, "Surname")
                XCTAssert(data["gender"] as? String == gender.code, "Gender")
                XCTAssert(data["date_of_birth"]  as? String == birthday.toStringServer, "Birthday")
                XCTAssert(data["notification"]  as? Bool == notification, "Notification")
                
                if let phone = data["mobile"] as? [String:Any] {
                    XCTAssert(phone["number"] as? String == phone["number"] as? String, "Phone number")
                    XCTAssert(phone["country_code"] as? String == phone["country_code"] as? String, "Phone cc")
                }else{
                    XCTFail()
                }
                
                if let address = data["address"] as? [String:Any] {
                    XCTAssert(address["line0"] as? String == address["line0"] as? String, "Address line0")
                    XCTAssert(address["line1"] as? String == address["line1"] as? String, "Address line1")
                    XCTAssert(address["line2"] as? String == address["line2"] as? String, "Address line2")
                    XCTAssert(address["city"] as? String == address["city"] as? String, "Address city")
                    XCTAssert(address["postal_code"] as? String == address["postal_code"] as? String, "Address postal_code")
                    XCTAssert(address["state"] as? String == address["state"] as? String, "Address state")
                    XCTAssert(address["country"] as? String == address["country"] as? String, "Address country")
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
    
    func testEditUserProfileDateOfBirth() {
        
        let expect = expectation(description: "editUserProfile")
        
        
        var userData = [String:Any]()
        userData["date_of_birth"] = "1992/15/25"
        
        
        APIManager.Instance.perform(call: .setUser, with: userData) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.DateOfBirth, "Wrong Error \(String(describing: error?.errorCode))")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testEditUserProfileGenderFormat() {
        
        let expect = expectation(description: "editUserProfile")
        
        
        var userData = [String:Any]()
        userData["gender"] = "HOLA"
        
        
        APIManager.Instance.perform(call: .setUser, with: userData) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.GenderFormat, "Wrong Error \(String(describing: error?.errorCode))")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testEditUserProfilePhoneFormat() {
        
        let expect = expectation(description: "editUserProfile")
        
        let phone = [
            "number": "123456789",
            "country_code":"AHH"
        ]

        
        var userData = [String:Any]()
        userData["mobile"] = phone
        
        
        APIManager.Instance.perform(call: .setUser, with: userData) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.PhoneFormat, "Wrong Error \(String(describing: error?.errorCode))")
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    

    //MARK:- ReadProfile
    
    func testReadUserProfileOk() {
        
        let expect = expectation(description: "readUserProfile")
        
        guard let id = SharedPreferences.get(.id) else {
            XCTFail()
            expect.fulfill()
            return
        }
        
        APIManager.Instance.perform(call: .getUser, withKey: id) { (error, data) in
            
            XCTAssertNil(error, "Error setting profile \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssertNotNil(data?["id"], "Missinging Id")
            XCTAssertNotNil(data?["email"], "Missinging Email")

            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }

    func testReadUserProfileUnauthorized() {
        
        let expect = expectation(description: "readUserProfile")
        
        let id = -1
        
        APIManager.Instance.perform(call: .getUser, withKey: id) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.Unauthorized, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- FriendList
    
    func testFriendListOk() {
        
        let expect = expectation(description: "FriendList")
        
        APIManager.Instance.perform(call: .friends) { (error, data) in
            
            XCTAssertNil(error, "Error FriendList \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            XCTAssertNotNil(data?["friendlist"], "No Friendlist found")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
