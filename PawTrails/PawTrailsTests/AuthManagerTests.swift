//
//  AuthManagerTests.swift
//  PawTrails
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class AuthManagerTests: XCTestCase {
    
    override func setUp() {
        let expect = expectation(description: "Example")
        APIAuthenticationTests().signIn { () in
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- SignUp
    
    func testSignUpOk() {
        let expect = expectation(description: "SignUp")
        let email = "register00@test.com"
        DataManager.Instance.signUp(email, ezdebug.password) { (error) in
            
            XCTAssertNil(error, "Error while registration \(String(describing: error))")
            XCTAssert(DataManager.Instance.isAuthenticated(), "Not authenticated properly")
            
            DataManager.Instance.getUser(callback: { (error, user) in
                
                XCTAssertNil(error, "Error while getting User \(String(describing: error))")
                XCTAssertNotNil(user, "User is nil :(\(String(describing: error))")
                XCTAssert(user?.id != nil, "Error in id")
                XCTAssert(user?.email == email, "Error in email while registration")
                
                guard let id = user?.id else {
                    XCTFail()
                    return
                }

                
                APIManager.Instance.perform(call: .deleteUser, withKey: id, callback: { (error, data) in
                    XCTAssertNil(error, "Error setting profile \(String(describing: error))")
                    expect.fulfill()
                })
            })
            
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpMissingEmail() {
        let expect = expectation(description: "SignUp")
        
        let email = ""
        let password = ezdebug.password
        
        DataManager.Instance.signUp(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpEmailFormat() {
        let expect = expectation(description: "SignUp")
        
        let email = "hello"
        let password = ezdebug.password
        
        DataManager.Instance.signUp(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpMissingPassword() {
        let expect = expectation(description: "SignUp")
        
        let email = "register1@test.com"
        let password = ""
        
        DataManager.Instance.signUp(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpWeakPassword() {
        let expect = expectation(description: "SignUp")
        
        let email = "register1@test.com"
        let password = "hello"
        
        DataManager.Instance.signUp(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.WeakPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpUserAlreadyExists() {
        let expect = expectation(description: "SignUp")
        
        let email = ezdebug.email
        let password = ezdebug.password
        
        DataManager.Instance.signUp(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.UserAlreadyExists, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    
    //MARK:- SignIn
    
    func testSignInOk() {
        let expect = expectation(description: "SignIn")
        
        let email = ezdebug.email
        let  password = ezdebug.password
        
        DataManager.Instance.signIn(email, password) { (error) in
            
            XCTAssertNil(error, "Error found \(String(describing: error))")
            XCTAssert(DataManager.Instance.isAuthenticated(), "Not authenticated properly")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInMissingEmail() {
        let expect = expectation(description: "SignIn")
        
        let email = ""
        let  password = ezdebug.password
        
        DataManager.Instance.signIn(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInEmailFormat() {
        let expect = expectation(description: "SignIn")
        
        let email = "hello"
        let  password = ezdebug.password
        
        DataManager.Instance.signIn(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInMissingPassword() {
        let expect = expectation(description: "SignIn")
        
        let email = ezdebug.email
        let  password = ""
        
        DataManager.Instance.signIn(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInWrongCredentials() {
        let expect = expectation(description: "SignIn")
        
        let email = ezdebug.email
        let  password = "hello"
        
        DataManager.Instance.signIn(email, password) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.WrongCredentials, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInUserDisabled() {
//        TODO
        
//        let expect = expectation(description: "SignIn")
//        
//        let email = ezdebug.email
//        let  password = "??"
//        
//        DataManager.Instance.signIn(email, password) { (error) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
//            
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
        
    }

    
    //MARK:- ResetPassword
    
    func testResetPasswordOk() {
        let expect = expectation(description: "ResetPassword")
        
        let email = ezdebug.email
        
        DataManager.Instance.sendPasswordReset(email) { (error) in
            
            XCTAssertNil(error, "Error found \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testResetPasswordMissingEmail() {
        let expect = expectation(description: "ResetPassword")
        
        let email = ""
        
        DataManager.Instance.sendPasswordReset(email) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testResetPasswordEmailFormat() {
        let expect = expectation(description: "ResetPassword")
        
        let email = "hello"
        
        DataManager.Instance.sendPasswordReset(email) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testResetPasswordUserNotFound() {
        let expect = expectation(description: "ResetPassword")
        
        let email = "hello@test.com"
        
        DataManager.Instance.sendPasswordReset(email) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.UserNotFound, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- ChangePassword
    
    func testChangePasswordOk() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password
        let newPassword = ezdebug.password + ";"
        
        DataManager.Instance.changeUsersPassword(email, password, newPassword) { (error) in
            
            XCTAssertNil(error, "Error found \(String(describing: error))")
            
            DataManager.Instance.changeUsersPassword(email, newPassword, password) { (error) in
                
                XCTAssertNil(error, "Error found \(String(describing: error))")
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordMissingEmail() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ""
        let password = ezdebug.password
        let newPassword = ezdebug.password + ";"
        
        DataManager.Instance.changeUsersPassword(email, password, newPassword) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordEmailFormat() {
        let expect = expectation(description: "ChangePassword")
        
        let email = "hello"
        let password = ezdebug.password
        let newPassword = ezdebug.password + ";"
        
        DataManager.Instance.changeUsersPassword(email, password, newPassword) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordMissingPassword() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ""
        let newPassword = ezdebug.password + ";"
        
        DataManager.Instance.changeUsersPassword(email, password, newPassword) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordMissingPassword2() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password
        let newPassword = ""
        
        DataManager.Instance.changeUsersPassword(email, password, newPassword) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordWeakPassword() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password
        let newPassword = "hey"
        
        DataManager.Instance.changeUsersPassword(email, password, newPassword) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.WeakPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordWrongPassword() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password + "hello"
        let newPassword = ezdebug.password + ";;"
        
        DataManager.Instance.changeUsersPassword(email, password, newPassword) { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.WrongPassword, "Wrong Error \(String(describing: error?.APIError?.errorCode))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- SignOut
    
    func testSignOutOk() {
        let expect = expectation(description: "SignOut")
        
        XCTAssert(DataManager.Instance.signOut())
        expect.fulfill()
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    

    
}
