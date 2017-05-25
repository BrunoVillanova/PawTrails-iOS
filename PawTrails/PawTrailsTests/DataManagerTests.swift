//
//  AuthManagerTests.swift
//  PawTrails
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class DataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
//        self.continueAfterFailure = false
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
    
    //MARK:- User
    
    
    func testSetUserOk() {
        
        
        
    }
    
    
    
    func getUser(callback: @escaping (User)->Swift.Void) {
        
        UserManager.get { (error, user) in
            
            XCTAssertNil(error, "Error while getting User \(String(describing: error))")
            XCTAssertNotNil(user, "User is nil :(\(String(describing: error))")
            if user == nil {XCTFail()}
            callback(user!)
        }
        
    }
    
    func save(_ userData:[String:Any], callback: @escaping userCallback) {
        
        DataManager.Instance.set(user: userData) { (error, user) in
            XCTAssertNil(error, "Error while saving User \(String(describing: error))")
            XCTAssertNotNil(user, "User is nil :(\(String(describing: error))")
            callback(error, user)
        }
    }
    
    func testGetUser() {
        let expect = expectation(description: "testGetUser")

        getUser { (user) in
            XCTAssertNotNil(user)
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testBasicReadWrite() {
        
        // Write
        
        let expect = expectation(description: "testBasicReadWrite")
        
        self.getUser { (user) in
            
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

            user.name = name
            user.surname = surname
            user.gender = gender.rawValue
            user.birthday = birthday
            user.notification = notification
            
//            let image = UIImage(named: "logo")
//            let data = UIImageJPEGRepresentation(image!, 0.5)
            
            var userData = [String:Any]()
            userData["name"] = name
            userData["surname"] = surname
            userData["gender"] = gender.code
            userData["date_of_birth"] = birthday.toStringServer
            userData["notification"] = notification
            userData["phone"] = phone
            userData["address"] = address
            
            

            self.save(userData, callback: { (error, user) in
                
                if let user = user {
                    XCTAssert(user.name == name, "Name not saved properly")
                    XCTAssert(user.surname == surname, "Surname not saved properly")
                    XCTAssert(user.gender == gender.rawValue, "Gender not saved properly")
                    XCTAssert(user.birthday?.toStringServer == birthday.toStringServer, "Birthday not saved properly")
                    XCTAssert(user.notification == notification, "Notification not saved properly")
                    XCTAssert(user.phone?.number == phone["number"], "Phone number not saved properly")
                    XCTAssert(user.phone?.country_code == phone["country_code"], "Phone cc not saved properly")
                    XCTAssert(user.address?.line0 == address["line0"], "Address line0 not saved properly")
                    XCTAssert(user.address?.line1 == address["line1"], "Address line1 not saved properly")
                    XCTAssert(user.address?.line2 == address["line2"], "Address line2 not saved properly")
                    XCTAssert(user.address?.city == address["city"], "Address city not saved properly")
                    XCTAssert(user.address?.postal_code == address["postal_code"], "Address postal_code not saved properly")
                    XCTAssert(user.address?.state == address["state"], "Address state not saved properly")
                    XCTAssert(user.address?.country == address["country"], "Address country not saved properly")
                    expect.fulfill()
                }
                
            })
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testBasicRemove() {
        
        // Write
        
        let expect = expectation(description: "testBasicRemove")
        
        self.getUser { (user) in
            
            var userData = [String:Any]()
            userData["name"] = ""
            userData["surname"] = ""
            userData["gender"] = ""
            userData["birthday"] = ""
            userData["notification"] = ""
            userData["phone"] = ""
            userData["address"] = ""
            
            
            
            self.save(userData, callback: { (error, user) in
                if let user = user {
                    XCTAssert(user.name == nil, "Name not saved properly")
                    XCTAssert(user.surname == nil, "Surname not saved properly")
                    XCTAssert(user.gender == 0, "Gender not saved properly")
                    XCTAssert(user.birthday == nil, "Birthday not saved properly")
                    XCTAssert(user.phone == nil, "Phone not saved properly")
                    XCTAssert(user.address == nil, "Address not saved properly")
                }
                expect.fulfill()
            })
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }    
}
