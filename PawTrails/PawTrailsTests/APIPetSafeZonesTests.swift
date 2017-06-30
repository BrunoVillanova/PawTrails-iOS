//
//  APIPetSafeZonesTests.swift
//  PawTrails
//
//  Created by Marc Perello on 24/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import PawTrails

class APIPetSafeZonesTests: XCTestCase {
    
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
    
    func getPet(_ callback: @escaping ((_ data:[String:Any]?)->())){
        APIManager.Instance.perform(call: .getPets) { (error, data) in
            
            if let data = data?["pets"].array {
                callback(data.first?.dictionaryObject)
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
                
                var _data = [String:Any]()
                _data["name"] = "SZ Test"
                _data["shape"] = Shape.circle.code
                _data["point1"] = self.point1
                _data["point2"] = self.point2
                _data["active"] = true
                _data["petid"] = petid
                
                APIManager.Instance.perform(call: .addSafeZone, with: _data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    self.checkSafeZone(data, _data)
                    
                    if let id = data?["id"].int {
                        callback(petid, id)
                    }else{
                        callback(nil, nil)
                    }
                }
            }
        }
    }
    
    func checkSafeZone(_ data: JSON?, _ _data: [String:Any]){
        if let data = data {
            XCTAssert(data["name"].string == _data["name"] as? String, "name")
            XCTAssert(data["shape"].int == _data["shape"] as? Int, "shape")
            
            XCTAssert(data["point1"]["lat"].double == self.point1["lat"] as? Double, "lat")
            XCTAssert(data["point1"]["lon"].double == self.point1["lon"] as? Double, "lat")
            
            XCTAssert(data["point2"]["lat"].double == self.point2["lat"] as? Double, "lat")
            XCTAssert(data["point2"]["lon"].double == self.point2["lon"] as? Double, "lon")
            
            XCTAssert(data["active"].bool == _data["active"] as? Bool, "active")
        }else{
            XCTFail()
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
                
                var _data = [String:Any]()
                _data["name"] = "SZ Test"
                _data["shape"] = Shape.circle.code
                _data["point1"] = self.point1
                _data["point2"] = self.point2
                _data["active"] = true
                _data["petid"] = id
                
                APIManager.Instance.perform(call: .addSafeZone, with: _data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    self.checkSafeZone(data, _data)
                    
                    if let id = data?["id"].int {
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
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    //MARK:- EditSafeZone

    func testEditSafeZoneOk() {
        let expect = expectation(description: "EditSafeZone")
        
        addSafeZone { (petid, id) in
            
            if let petid = petid, let id = id {
                
                var _data = [String:Any]()
                _data["id"] = id
                _data["name"] = "SZ Test"
                _data["shape"] = Shape.circle.code
                _data["point1"] = self.point1
                _data["point2"] = self.point2
                _data["active"] = true
                _data["petid"] = petid
                
                APIManager.Instance.perform(call: .setSafeZone, with: _data) { (error, data) in
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    XCTAssertNotNil(data, "No data :(")
                    
                    self.checkSafeZone(data, _data)
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
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
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
                    
                    if let id = data?["id"].int {
                        APIManager.Instance.perform(call: .removeSafeZone, withKey: id) { (error, data) in
                            XCTAssertNil(error, "Error \(String(describing: error))")
                            XCTAssertNotNil(data, "No data :(")
                            expect.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
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
                    
                    if let id = data?["id"].int {
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
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
