//
//  AuthManagerTests.swift
//  Snout
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import Snout

class AuthManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegister() {
        let expect = expectation(description: "Example")
        let email = "register1@test.com"
        AuthManager.Instance.register(email, ezdebug.password) { (error) in
            if error == nil {
                XCTAssert(AuthManager.Instance.isAuthenticated(), "Not authenticated properly")
                UserManager.getUser({ (error, user) in
                    if error == nil && user != nil {
                        XCTAssert(user!.email == email, "Error in email while registration")
                    }else{
                        XCTAssert(error == nil, "Found error getting user form CDST \(error)")
                        XCTAssert(user != nil, "User is nil :(")
                    }
                })
            }else{
                XCTFail("Error while registration \(error)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 10000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testLogIn() {
        let expect = expectation(description: "Example")
        AuthManager.Instance.signIn(ezdebug.email, ezdebug.password) { (error) in
            XCTAssert(error == nil, "Error found \(error)")
            XCTAssert(AuthManager.Instance.isAuthenticated(), "Not authenticated properly")
            expect.fulfill()
        }
        waitForExpectations(timeout: 10000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
}
