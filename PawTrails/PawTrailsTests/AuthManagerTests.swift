//
//  AuthManagerTests.swift
//  Snout
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

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
        AuthManager.Instance.signUp(email, ezdebug.password) { (error) in
            
            XCTAssertNil(error, "Error while registration \(error)")
            XCTAssert(AuthManager.Instance.isAuthenticated(), "Not authenticated properly")
            
            UserManager.get({ (error, user) in
                
                XCTAssertNil(error, "Found error getting user form CDST \(error)")
                XCTAssertNotNil(error, "User is nil :(")
                XCTAssert(user!.email == email, "Error in email while registration")
                
            })
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(error)")
        }
    }
    
    func testSignIn() {
        let expect = expectation(description: "Example")
        AuthManager.Instance.signIn(ezdebug.email, ezdebug.password) { (error) in
            XCTAssertNil(error, "Error found \(error)")
            XCTAssert(AuthManager.Instance.isAuthenticated(), "Not authenticated properly")
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(error)")
        }
    }
    
}
