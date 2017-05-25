//
//  APIPetSafeZonesTests.swift
//  PawTrails
//
//  Created by Marc Perello on 24/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class APIPetSafeZonesTests: XCTestCase {
    
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
    
    func getPet(_ callback: @escaping ((_ data:[String:Any]?)->())){
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            
            if let data = data?["pets"] as? [[String:Any]] {
                callback(data.first)
            }else{
                callback(nil)
            }
        }
    }

    let point1 = Point(5, 5).toDict
    let point2 = Point(5, 5.1).toDict

    func addSafeZone(callback: @escaping ((Int?, Int?)->())){
        getPet { (pet) in
            
            if let petid = pet?.tryCastInteger(for: "id") {
                
                var data = [String:Any]()
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = petid
                
                APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    if let id = data?.tryCastInteger(for: "id") {
                        callback(petid, id)
                    }else{
                        callback(nil, nil)
                    }
                }
            }
        }
    }
    
    func remove(safezone id: Int, callback: @escaping ((Bool)->())){
        APIManager.Instance.perform(call: .removeSafeZone, withKey: id) { (error, data) in
            callback(error==nil)
        }
    }
    
    //MARK:- AddSafeZone
    
    
    func testAddSafeZoneOk() {
        let expect = expectation(description: "AddSafeZone")
        
        
        getPet { (pet) in
            
            if let id = pet?.tryCastInteger(for: "id") {
                
                var data = [String:Any]()
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = id
                
                APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    if let id = data?.tryCastInteger(for: "id") {
                        self.remove(safezone: id, callback: { (success) in
                            XCTAssert(success, "Not removes properly")
                            expect.fulfill()
                        })
                    }else{
                        XCTFail()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSafeZoneMissingSafeZoneName() {
        let expect = expectation(description: "AddSafeZone")
        
        
        getPet { (pet) in
            
            if let id = pet?.tryCastInteger(for: "id") {
                
                var data = [String:Any]()
                
                data["shape"] = Shape.circle.code
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = id
                
                APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
                    XCTAssertNotNil(error)
                    XCTAssert(error?.errorCode == ErrorCode.MissingSafeZoneName, "Wrong Error \(String(describing: error?.errorCode))")
                    expect.fulfill()
                    
                }
            }
        }
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSafeZoneWrongShapeFormat() {
        let expect = expectation(description: "AddSafeZone")
        
        
        getPet { (pet) in
            
            if let id = pet?.tryCastInteger(for: "id") {
                
                var data = [String:Any]()
                
                data["name"] = "SZ Test"
                data["shape"] = 25
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = id
                
                APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
                    XCTAssertNotNil(error)
                    XCTAssert(error?.errorCode == ErrorCode.WrongShapeFormat, "Wrong Error \(String(describing: error?.errorCode))")
                    expect.fulfill()
                    
                }
            }
        }
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSafeZoneCoordinatesOutOfBounds() {
        let expect = expectation(description: "AddSafeZone")
        
        
        getPet { (pet) in
            
            if let id = pet?.tryCastInteger(for: "id") {
                
                var data = [String:Any]()
                
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = Point(-500, 500).toDict
                data["point2"] = Point(-500, 500).toDict
                data["active"] = true
                data["petid"] = id
                
                APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
                    XCTAssertNotNil(error)
                    XCTAssert(error?.errorCode == ErrorCode.CoordinatesOutOfBounds, "Wrong Error \(String(describing: error?.errorCode))")
                    expect.fulfill()
                    
                }
            }
        }
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    //MARK:- EditSafeZone

    func testEditSafeZoneOk() {
        let expect = expectation(description: "EditSafeZone")
        
        addSafeZone { (petid, id) in
            
            if let petid = petid, let id = id {
                
                var data = [String:Any]()
                data["id"] = id
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = petid
                
                APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testEditSafeZoneWrongShapeFormat() {
        let expect = expectation(description: "EditSafeZone")
        
        addSafeZone { (petid, id) in
            
            if let petid = petid, let id = id {
                
                var data = [String:Any]()
                data["id"] = id
                data["name"] = "SZ Test"
                data["shape"] = 25
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = petid
                
                APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
                    XCTAssertNotNil(error)
                    XCTAssert(error?.errorCode == ErrorCode.WrongShapeFormat, "Wrong Error \(String(describing: error?.errorCode))")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testEditSafeZoneCoordinatesOutOfBounds() {
        let expect = expectation(description: "EditSafeZone")
        
        addSafeZone { (petid, id) in
            
            if let petid = petid, let id = id {
                
                var data = [String:Any]()
                data["id"] = id
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = Point(-50000, 5).toDict
                data["point2"] = Point(-5, 5).toDict
                data["active"] = true
                data["petid"] = petid
                
                APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
                    XCTAssertNotNil(error)
                    XCTAssert(error?.errorCode == ErrorCode.CoordinatesOutOfBounds, "Wrong Error \(String(describing: error?.errorCode))")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testEditSafeZoneSafeZoneNotFound() {
        let expect = expectation(description: "EditSafeZone")
        
        addSafeZone { (petid, id) in
            
            if let petid = petid, let id = id {
                
                var data = [String:Any]()
                data["id"] = 0
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = petid
                
                APIManager.Instance.perform(call: .setSafeZone, with: data) { (error, data) in
                    XCTAssertNotNil(error)
                    XCTAssert(error?.errorCode == ErrorCode.SafeZoneNotFound, "Wrong Error \(String(describing: error?.errorCode))")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }

    //MARK:- RemoveSafeZone
    

    func testRemoveSafeZoneOk() {
        let expect = expectation(description: "AddSafeZone")
        
        
        getPet { (pet) in
            
            if let id = pet?.tryCastInteger(for: "id") {
                
                var data = [String:Any]()
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = id
                
                APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    if let id = data?.tryCastInteger(for: "id") {
                        APIManager.Instance.perform(call: .removeSafeZone, withKey: id) { (error, data) in
                            XCTAssertNil(error, "Error \(String(describing: error))")
                            XCTAssertNotNil(data, "No data :(")
                            expect.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testRemoveSafeZoneSafeZoneNotFound() {
        let expect = expectation(description: "AddSafeZone")
        
        getPet { (pet) in
            
            if let id = pet?.tryCastInteger(for: "id") {
                
                var data = [String:Any]()
                data["name"] = "SZ Test"
                data["shape"] = Shape.circle.code
                data["point1"] = self.point1
                data["point2"] = self.point2
                data["active"] = true
                data["petid"] = id
                
                APIManager.Instance.perform(call: .addSafeZone, with: data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    if let id = data?.tryCastInteger(for: "id") {
                        APIManager.Instance.perform(call: .removeSafeZone, withKey: 0) { (error, data) in
                            XCTAssertNotNil(error)
                            XCTAssert(error?.errorCode == ErrorCode.SafeZoneNotFound, "Wrong Error \(String(describing: error?.errorCode))")

                            self.remove(safezone: id, callback: { (success) in
                                XCTAssert(success, "Not removes properly")
                                expect.fulfill()
                            })
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
