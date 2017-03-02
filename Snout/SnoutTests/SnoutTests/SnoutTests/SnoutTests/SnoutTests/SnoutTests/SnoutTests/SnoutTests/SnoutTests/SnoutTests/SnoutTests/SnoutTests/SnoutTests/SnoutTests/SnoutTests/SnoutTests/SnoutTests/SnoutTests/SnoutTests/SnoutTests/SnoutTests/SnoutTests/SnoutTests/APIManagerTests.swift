//
//  APIManagerTests.swift
//  Snout
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import Snout

class APIManagerTests: XCTestCase {
    
    func testRegister() {
        
        let expect = expectation(description: "register")
        let email = "registerAPI0@test.com"
        let data = ["email":email, "password":ezdebug.password]
        APIManager.Instance.performCall(.register, data) { (error, data) in
            
            if error == nil && data != nil {
                
                self.found(key: "token", in: data!)
                let userData = self.get(key: "user", in: data!) as? [String:Any]
                self.found(key: "id", in: userData!)
                self.found(key: "email", in: userData!)
                
                XCTAssert(userData?["email"] is String, "Failed to login email wrong format")
                XCTAssert(userData?["email"] as! String == email, "Failed to login with proper email")
                
            }else{ XCTFail("Error register in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)") }
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }
    
    func testSignIn() {
        
        let expect = expectation(description: "sign in")
        
        let data = ["email":ezdebug.email, "password":ezdebug.password]
        APIManager.Instance.performCall(.signin, data) { (error, data) in
            
            if error == nil && data != nil {
                
                self.found(key: "token", in: data!)
                let userData = self.get(key: "user", in: data!) as? [String:Any]
                self.found(key: "id", in: userData!)
                self.found(key: "email", in: userData!)
                
                XCTAssert(userData?["email"] is String, "Failed to login email wrong format")
                XCTAssert(userData?["email"] as! String == ezdebug.email, "Failed to login with proper email")
                
            }else { XCTFail("Error signin in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)") }
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }
    
    func testPasswordChange() {
        
        let expect = expectation(description: "password change")
        
        AuthManager.Instance.signIn(ezdebug.email, ezdebug.password) { (error) in
            XCTAssert(error == nil, "Couldn't sign in properly \(error)")
            
            let newPassword = "Attitude2004"
            
            let data = ["id":SharedPreferences.get(.id), "email":ezdebug.email, "password":ezdebug.password, "new_password":newPassword]
            APIManager.Instance.performCall(.passwordChange, data) { (error, data) in
                
                XCTAssert(error == nil, "Error password change in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)")
                
                let data = ["id":SharedPreferences.get(.id), "email":ezdebug.email, "password":newPassword, "new_password":ezdebug.password]
                APIManager.Instance.performCall(.passwordChange, data) { (error, data) in
                    
                    XCTAssert(error == nil, "Error password change in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)")
                    
                    AuthManager.Instance.signIn(ezdebug.email, ezdebug.password) { (error) in
                        XCTAssert(error == nil, "Couldn't sign in properly once the password is changed back\(error)")
                    }
                    expect.fulfill()
                }
            }

        }
        
        
        
        waitForExpectations(timeout: 100) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }
    
    func testGetUser() {
        
        let expect = expectation(description: "get user")
        
        APIManager.Instance.performCall(.getuser) { (error, data) in
            
            if error == nil && data != nil {
                
                let userData = self.get(key: "user", in: data!) as? [String:Any]
                self.found(key: "id", in: userData!)
                self.found(key: "email", in: userData!)
                
                XCTAssert(userData?["email"] is String, "Failed to login email wrong format")
                XCTAssert(userData?["email"] as! String == ezdebug.email, "Failed to login with proper email")
                
            }else { XCTFail("Error get user in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)") }
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }
    

    private func found(key:String, in data:[String:Any]){
        guard data[key] != nil else {
            XCTFail("Error \(key) not found")
            return
        }
    }
    
    private func get(key:String, in data:[String:Any]) -> Any? {
        guard let out = data[key] else {
            XCTFail("Error \(key) not found")
            return nil
        }
        return out
    }
}
