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
    
    func testSignUp() {
        
        let expect = expectation(description: "signUp")
        let email = "registerAPI0@test.com"
        let data = ["email":email, "password":ezdebug.password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            
            if error == nil && data != nil {
                
                self.XCTFound(key: "token", in: data!)
                let userData = self.XCTGet(key: "user", in: data!) as? [String:Any]
                self.XCTFound(key: "id", in: userData!)
                self.XCTFound(key: "email", in: userData!)
                
                XCTAssert(userData?["email"] is String, "Failed to login email wrong format")
                XCTAssert(userData?["email"] as! String == email, "Failed to login with proper email")
                
            }else{ XCTFail("Error register in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)") }
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }

    func testSignIn() {
        
        let expect = expectation(description: "sign in")
        signIn { (_, _) in
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }
    
    func signIn(callback: @escaping (_ id:String,_ token:String) -> Swift.Void) {
        
        let data = ["email":ezdebug.email, "password":ezdebug.password]
        APIManager.Instance.perform(call: .signin,  with: data) { (error, data) in
            
            if error == nil && data != nil {
                
                let token = self.XCTGet(key: "token", in: data!) as! String
                let userData = self.XCTGet(key: "user", in: data!) as? [String:Any]
                let id = self.XCTGet(key: "id", in: userData!) as! String
                self.XCTFound(key: "email", in: userData!)
                
                XCTAssert(userData?["email"] is String, "Failed to login email wrong format")
                XCTAssert(userData?["email"] as! String == ezdebug.email, "Failed to login with proper email")
                
                callback(id,token)
                
            }else { XCTFail("Error signin in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)") }
        }
    }

    func testPasswordChange() {
        
        let expect = expectation(description: "password change")
        
        AuthManager.Instance.signIn(ezdebug.email, ezdebug.password) { (error) in
            XCTAssert(error == nil, "Couldn't sign in properly \(error)")
            
            let newPassword = "Attitude2004"
            
            let data = ["id":SharedPreferences.get(.id), "email":ezdebug.email, "password":ezdebug.password, "new_password":newPassword]
            APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
                
                XCTAssert(error == nil, "Error password change in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)")
                
                let data = ["id":SharedPreferences.get(.id), "email":ezdebug.email, "password":newPassword, "new_password":ezdebug.password]
                APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
                    
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
        
        let expect = expectation(description: "set user")
        
        signIn { (id, token) in
            
            SharedPreferences.set(.id, with: id)
            SharedPreferences.set(.token, with: token)
            
            APIManager.Instance.perform(call: .getUser) { (error, data) in
                
                if error == nil && data != nil {
                    
                    let userData = self.XCTGet(key: "user", in: data!) as? [String:Any]
                    self.XCTFound(key: "id", in: userData!)
                    self.XCTFound(key: "email", in: userData!)
                    
                    XCTAssert(userData?["email"] is String, "Failed to login email wrong format")
                    XCTAssert(userData?["email"] as! String == ezdebug.email, "Failed to login with proper email")
                    
                }else { XCTFail("Error get user in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)") }
                
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 100) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }
    
    func testSetUser() {
        
        let expect = expectation(description: "set user")
        
        signIn { (id, token) in
            
            SharedPreferences.set(.id, with: id)
            SharedPreferences.set(.token, with: token)
            
            let name = "John"
            let surname = "Smith"
            let gender = "F"
            let birthday = "1995-03-16"
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
            
            var data = [String:Any]()
            data["id"] = SharedPreferences.get(.id)      
            data["name"] = name
            data["surname"] = surname
            data["gender"] = gender
            data["date_of_birth"] = birthday
            data["notification"] = notification
            data["mobile"] = phone
            data["address"] = address
            
            APIManager.Instance.perform(call: .setUser, with: data) { (error, data) in
                
                if error == nil && data != nil {
                    
                    let userData = self.XCTGet(key: "user", in: data!) as? [String:Any]
                    
                    self.XCTFound(key: "id", in: userData!)
                    self.XCTMatch(key: "email", value: ezdebug.email, in: userData!)
                    self.XCTMatch(key: "name", value: name, in: userData!)
                    self.XCTMatch(key: "surname", value: surname, in: userData!)
                    self.XCTMatch(key: "gender", value: gender, in: userData!)
                    self.XCTMatch(key: "date_of_birth", value: birthday, in: userData!)
                    self.XCTMatch(key: "notification", value: notification, in: userData!)
                    
                    let phoneData = self.XCTGet(key: "mobile", in: userData!) as? [String:Any]
                    self.XCTMatch(key: "number", value: phone["number"]!, in: phoneData!)
                    self.XCTMatch(key: "country_code", value: phone["country_code"]!, in: phoneData!)
                    
                    let addressData = self.XCTGet(key: "address", in: userData!) as? [String:Any]
                    self.XCTMatch(key: "line0", value: address["line0"]!, in: addressData!)
                    self.XCTMatch(key: "line1", value: address["line1"]!, in: addressData!)
                    self.XCTMatch(key: "line2", value: address["line2"]!, in: addressData!)
                    self.XCTMatch(key: "city", value: address["city"]!, in: addressData!)
                    self.XCTMatch(key: "postal_code", value: address["postal_code"]!, in: addressData!)
                    self.XCTMatch(key: "state", value: address["state"]!, in: addressData!)
                    self.XCTMatch(key: "country", value: address["country"]!, in: addressData!)
                    
                }else { XCTFail("Error set user in \(AuthenticationError(rawValue: error!.specificCode)) \(error) \(data)") }
                
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(error)") } }
    }
}

public extension XCTest {
    
    public func XCTFound(key:String, in data:[String:Any]){
        guard data[key] != nil else {
            XCTFail("Error \(key) not found")
            return
        }
    }
    
   
    public func XCTMatch <T: Equatable> (key:String, value:T, in data:[String:Any]){
        guard data[key] != nil else {
            XCTFail("Error \(key) not found")
            return
        }
        if data[key] is T  {
            XCTAssert((data[key] as! T) == value, "\(key) not match \(data[key]) != \(value)")
            return
        }else{
            XCTFail("\(key) has wrong object type match \(data[key]) != \(value)")
            return
        }
    }
    
    public func XCTGet(key:String, in data:[String:Any]) -> Any {
        guard let out = data[key] else {
            XCTFail("Error \(key) not found")
            return ""
        }
        return out
    }

}
