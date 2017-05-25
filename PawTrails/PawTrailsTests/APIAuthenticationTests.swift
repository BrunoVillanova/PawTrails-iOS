//
//  APIAuthenticationTests.swift
//  PawTrails
//
//  Created by Marc Perello on 24/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class APIAuthenticationTests: XCTestCase {
    
    
    public func signIn(email: String = ezdebug.email, password: String = ezdebug.password, callback: @escaping ((_ id: String, _ token: String)->())){
        let data = ["email":email, "password":password]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            
            
            guard let token = data?["token"] as? String else {
                fatalError("token missing")
            }
            guard let userData = data?["user"] as? [String:Any] else {
                fatalError("user missing")
            }
            
            guard let id = userData.tryCastInteger(for: "id") else {
                fatalError("id missing")
            }
            callback("\(id)",token)
        }
    }
    
    override func setUp() {
        super.setUp()
        let expect = expectation(description: "Example")
        signIn { (id, token) in
            SharedPreferences.set(.id, with: id)
            SharedPreferences.set(.token, with: token)
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- SignUp
    
    func testSignUpOk() {
        let expect = expectation(description: "SignUp")
        
        let email = "register00@test.com"
        let password = ezdebug.password
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error setting profile \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            XCTAssertNotNil(data?["token"], "token not found")
            XCTAssertNotNil(data?["user"], "token not found")
            
            guard let userData = data?["user"] as? [String:Any] else {
                XCTFail()
                return
            }
            
            guard let id = userData.tryCastInteger(for: "id") else {
                XCTFail()
                return
            }
            
            XCTAssert(userData["email"] is String, "Failed to login email wrong format")
            XCTAssert(userData["email"] as! String == email, "Failed to login with proper email")

            
            APIManager.Instance.perform(call: .deleteUser, withKey: id, completition: { (error, data) in
                XCTAssertNil(error, "Error setting profile \(String(describing: error))")
                expect.fulfill()
            })
            
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpMissingEmail() {
        let expect = expectation(description: "SignUp")
        
        let email = ""
        let password = ezdebug.password
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpEmailFormat() {
        let expect = expectation(description: "SignUp")
        
        let email = "hello"
        let password = ezdebug.password
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpMissingPassword() {
        let expect = expectation(description: "SignUp")
        
        let email = "register1@test.com"
        let password = ""
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpWeakPassword() {
        let expect = expectation(description: "SignUp")
        
        let email = "register1@test.com"
        let password = "hello"
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WeakPassword, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignUpUserAlreadyExists() {
        let expect = expectation(description: "SignUp")
        
        let email = ezdebug.email
        let password = ezdebug.password
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.UserAlreadyExists, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    
    //MARK:- SignIn
    
    func testSignInOk() {
        let expect = expectation(description: "SignIn")
        
        let email = ezdebug.email
        let  password = ezdebug.password
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error setting profile \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            
            XCTAssertNotNil(data?["token"], "token not found")
            XCTAssertNotNil(data?["user"], "token not found")
            
            guard let userData = data?["user"] as? [String:Any] else {
                XCTFail()
                return
            }
            
            guard userData.tryCastInteger(for: "id") != nil else {
                XCTFail()
                return
            }
            
            XCTAssert(userData["email"] is String, "Failed to login email wrong format")
            XCTAssert(userData["email"] as! String == email, "Failed to login with proper email")

            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInMissingEmail() {
        let expect = expectation(description: "SignIn")
        
        let email = ""
        let  password = ezdebug.password
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInEmailFormat() {
        let expect = expectation(description: "SignIn")
        
        let email = "hello"
        let  password = ezdebug.password
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInMissingPassword() {
        let expect = expectation(description: "SignIn")
        
        let email = ezdebug.email
        let  password = ""
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testSignInWrongCredentials() {
        let expect = expectation(description: "SignIn")
        
        let email = ezdebug.email
        let  password = "hello"
        
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WrongCredentials, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
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
//        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
//        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
//            
//            XCTAssertNotNil(error)
//            XCTAssert(error?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error))")
//            
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 100) { error in
//            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
//        }
        
    }
    
    
    //MARK:- ResetPassword
    
    func testResetPasswordOk() {
        let expect = expectation(description: "ResetPassword")
        
        let email = ezdebug.email
        
        let data = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]
        
        APIManager.Instance.perform(call: .passwordReset, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error found \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testResetPasswordMissingEmail() {
        let expect = expectation(description: "ResetPassword")
        
        let email = ""
        
        let data = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]
        
        APIManager.Instance.perform(call: .passwordReset, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testResetPasswordEmailFormat() {
        let expect = expectation(description: "ResetPassword")
        
        let email = "hello"
        
        let data = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]
        
        APIManager.Instance.perform(call: .passwordReset, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testResetPasswordUserNotFound() {
        let expect = expectation(description: "ResetPassword")
        
        let email = "hello@test.com"
        
        let data = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]
        
        APIManager.Instance.perform(call: .passwordReset, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.UserNotFound, "Wrong Error \(String(describing: error))")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- ChangePassword
    
    func testChangePasswordOk() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password
        let newPassword = ezdebug.password + ";"
        
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error found \(String(describing: error))")
            
            let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":newPassword, "new_password":password]
            APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
                
                XCTAssertNil(error, "Error found \(String(describing: error))")
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordMissingEmail() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ""
        let password = ezdebug.password
        let newPassword = ezdebug.password + ";"
        
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingEmail, "Wrong Error \(String(describing: error))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordEmailFormat() {
        let expect = expectation(description: "ChangePassword")
        
        let email = "hello"
        let password = ezdebug.password
        let newPassword = ezdebug.password + ";"
        
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.EmailFormat, "Wrong Error \(String(describing: error))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordMissingPassword() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ""
        let newPassword = ezdebug.password + ";"
        
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordMissingPassword2() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password
        let newPassword = ""
        
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingPassword, "Wrong Error \(String(describing: error))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordWeakPassword() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password
        let newPassword = "hey"
        
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WeakPassword, "Wrong Error \(String(describing: error))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testChangePasswordWrongPassword() {
        let expect = expectation(description: "ChangePassword")
        
        let email = ezdebug.email
        let password = ezdebug.password + "hello"
        let newPassword = ezdebug.password + ";;"
        
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.WrongPassword, "Wrong Error \(String(describing: error))")
            expect.fulfill()
            
        }
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
}
