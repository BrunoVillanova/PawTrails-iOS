//
//  ImageUploadTest.swift
//  PawTrails
//
//  Created by Marc Perello on 23/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class APIImageUploadTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
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

    func testUploadUserImageOk() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            
            XCTAssertNil(error, "Error \(String(describing: error))")
            XCTAssertNotNil(data, "No data :(")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testUploadUserImagePathFormat() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = ""
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.PathFormat, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testUploadUserImageMissingUserId() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingUserId, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testUploadPetImageOk() {
        
        let expect = expectation(description: "UploadImage")
        
        PetManager.getPets { (error, pets) in
            
            if error == nil, let pets = pets {
                
                var data = [String:Any]()
                data["path"] = "pet"
                data["petid"] = pets.first?.id ?? -1
                data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
                
                APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    expect.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testUploadPetImageMissingPetId() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = "pet"
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "logo")!, 0.9)
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingPetId, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testUploadUserImageMissingImageFile() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.MissingImageFile, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testUploadUserImageIncorrectImageMime() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImagePNGRepresentation(UIImage(named: "logo")!)
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.IncorrectImageMime, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testUploadUserImageImageFileSize() {
        
        let expect = expectation(description: "UploadImage")
        
        var data = [String:Any]()
        data["path"] = "user"
        data["userid"] = SharedPreferences.get(.id)
        data["picture"] = UIImageJPEGRepresentation(UIImage(named: "bigImage")!, 1.0)
        
        APIManager.Instance.perform(call: .imageUpload, with: data) { (error, data) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.errorCode == ErrorCode.ImageFileSize, "Wrong Error \(String(describing: error?.errorCode))")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
