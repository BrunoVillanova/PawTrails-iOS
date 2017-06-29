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
        APIAuthenticationTests().signIn { () in
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
        userData["id"] = SharedPreferences.get(.id)
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
                XCTAssert(data["name"].stringValue == name, "Name")
                XCTAssert(data["surname"].stringValue == surname, "Surname")
                XCTAssert(data["gender"].stringValue == gender.code, "Gender")
                XCTAssert(data["date_of_birth"].stringValue == birthday.toStringServer, "Birthday")
                XCTAssert(data["notification"].boolValue == notification, "Notification")
                

                XCTAssert(data["mobile"]["number"].stringValue == phone["number"], "Phone number")
                XCTAssert(data["mobile"]["country_code"].stringValue == phone["country_code"], "Phone cc")

                
                XCTAssert(data["address"]["line0"].stringValue == address["line0"], "Address line0")
                XCTAssert(data["address"]["line1"].stringValue == address["line1"], "Address line1")
                XCTAssert(data["address"]["line2"].stringValue == address["line2"], "Address line2")
                XCTAssert(data["address"]["city"].stringValue == address["city"], "Address city")
                XCTAssert(data["address"]["postal_code"].stringValue == address["postal_code"], "Address postal_code")
                XCTAssert(data["address"]["state"].stringValue == address["state"], "Address state")
                XCTAssert(data["address"]["country"].stringValue == address["country"], "Address country")
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
        
        let id = SharedPreferences.get(.id)
        
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
