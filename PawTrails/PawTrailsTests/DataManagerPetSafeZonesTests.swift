//
//  DataManagerPetSafeZonesTests.swift
//  PawTrails
//
//  Created by Marc Perello on 06/06/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class DataManagerPetSafeZonesTests: XCTestCase {
    
    override func setUp() {
        let expect = expectation(description: "Example")
        APIAuthenticationTests().signIn { () in
            expect.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func getPet(_ callback: @escaping ((Pet?)->())){
        DataManager.Instance.getPets { (error, pets) in
            callback(pets?.first(where: { $0.isOwner }))
        }
    }
    
    let point1 = Point(5, 5).toDict
    let point2 = Point(5, 5.1).toDict
    
    //MARK:- LoadSafeZones
    
    func testLoadSafeZonesOk() {
        let expect = expectation(description: "LoadSafeZones")
        
        getPet { (pet) in
            if let pet = pet {
                
                DataManager.Instance.loadSafeZones(of: pet.id, callback: { (error) in
                    
                    XCTAssertNil(error, String(describing: error))
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testLoadSafeZonesNotEnoughRights() {
        let expect = expectation(description: "LoadSafeZones")
        
        DataManager.Instance.loadSafeZones(of: 0, callback: { (error) in
            
            XCTAssertNotNil(error, String(describing: error))
            XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, String(describing: error))
            expect.fulfill()
        })

        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- AddSafeZones
    
    private func remove(safezone id: Int, callback: @escaping ((Bool)->())){
        APIManager.Instance.perform(call: .removeSafeZone, withKey: id) { (error, data) in
            callback(error==nil)
        }
    }
    
    func testAddSafeZoneOk() {
        let expect = expectation(description: "AddSafeZone")
        
        getPet { (pet) in
            
            if let id = pet?.id {
                
                let safezone = SafeZone(id: 0, name: "SZ", point1: Point(self.point1), point2: Point(self.point2), shape: Shape.circle, active: true, address: nil, preview: nil)
                
                DataManager.Instance.add(safezone, to: id, callback: { (error, safezone) in

                    XCTAssertNil(error, "Error \(String(describing: error))")
                    
                    if let id = safezone?.id {
                        self.remove(safezone: id, callback: { (success) in
                            XCTAssert(success, "Not removed properly")
                            expect.fulfill()
                        })
                    }else{
                        XCTFail()
                    }
                })
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSafeZoneMissingSafeZoneName() {
        let expect = expectation(description: "AddSafeZone")
        
        getPet { (pet) in
            
            if let id = pet?.id {

                let safezone = SafeZone(id: 0, name: nil, point1: Point(self.point1), point2: Point(self.point2), shape: Shape.circle, active: true, address: nil, preview: nil)
                
                DataManager.Instance.add(safezone, to: id, callback: { (error, _) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.MissingSafeZoneName, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
        
    }
    
    func testAddSafeZoneWrongShapeFormat() {
//        let expect = expectation(description: "AddSafeZone")
//        
//        getPet { (pet) in
//            
//            if let id = pet?.id {
//                
//                var data = [String:Any]()
//                data["name"] = "SZ Test"
//                data["shape"] = 25
//                data["point1"] = self.point1
//                data["point2"] = self.point2
//                data["active"] = true
//                data["petid"] = id
//                
//                DataManager.Instance.addSafeZone(by: data, to: id, callback: { (error, _) in
//                    
//                    
//                    XCTAssertNotNil(error)
//                    XCTAssert(error?.APIError?.errorCode == ErrorCode.WrongShapeFormat, "Wrong Error \(String(describing: error))")
//                    expect.fulfill()
//                })
//            }
//        }
//        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testAddSafeZoneCoordinatesOutOfBounds() {
        let expect = expectation(description: "AddSafeZone")

        getPet { (pet) in
            
            if let id = pet?.id {
                
                let safezone = SafeZone(id: 0, name: "SZ", point1: Point(-500, 500), point2: Point(-500, 500), shape: Shape.circle, active: true, address: nil, preview: nil)
                
                DataManager.Instance.add(safezone, to: id, callback: { (error, _) in
                    
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.CoordinatesOutOfBounds, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }

    //MARK:- SetSafeZone
    
    private func addSafeZone(callback: @escaping ((_ id: Int, _ sz:SafeZone?)->())){
        
        getPet { (pet) in
            if let pet = pet {
                
                let safezone = SafeZone(id: 0, name: "SZ", point1: Point(self.point1), point2: Point(self.point2), shape: Shape.circle, active: true, address: nil, preview: nil)
                
                DataManager.Instance.add(safezone, to: pet.id, callback: { (error, safezone) in
                    if error == nil, let safezone = safezone {
                        callback(pet.id, safezone)
                    }else{
                        debugPrint(error ?? "nil error")
                        callback(pet.id, nil)
                    }
                })
            }
        }
    }
    
    func testSetSafeZoneOk() {
        let expect = expectation(description: "SetSafeZone")
        
        addSafeZone { (petId, safezone) in
            
            if var safezone = safezone {
                
                safezone.name = "SZ Test"
                safezone.shape = Shape.circle
                safezone.point1 = Point(self.point1)
                safezone.point2 = Point(self.point2)
                safezone.active = true
                
                DataManager.Instance.save(safezone, into: petId, callback: { (error) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")

                    self.remove(safezone: safezone.id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                })
            }else{
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetSafeZoneWrongShapeFormat() {
//        let expect = expectation(description: "SetSafeZone")
//        
//        addSafeZone { (petid, safezone) in
//            
//            if let id = safezone?.id {
//                
//                var data = [String:Any]()
//                data["id"] = id
//                data["name"] = "SZ Test"
//                data["shape"] = 25
//                data["point1"] = self.point1
//                data["point2"] = self.point2
//                data["active"] = true
//                data["petid"] = petid
//                
//                DataManager.Instance.setSafeZone(by: data, to: petid, callback: { (error) in
//                    
//                    XCTAssertNotNil(error)
//                    XCTAssert(error?.APIError?.errorCode == ErrorCode.WrongShapeFormat, "Wrong Error \(String(describing: error))")
//                    
//                    self.remove(safezone: id, callback: { (success) in
//                        XCTAssert(success, "Not removes properly")
//                        expect.fulfill()
//                    })
//                })
//            }
//        }
//        
//        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetSafeZoneCoordinatesOutOfBounds() {
        let expect = expectation(description: "SetSafeZone")
        addSafeZone { (petId, safezone) in
            
            if var safezone = safezone {
                
                safezone.name = "SZ Test"
                safezone.shape = Shape.circle
                safezone.point1 = Point(-50000, 5)
                safezone.point2 = Point(-5, 5)
                safezone.active = true
                
                DataManager.Instance.save(safezone, into: petId, callback: { (error) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.CoordinatesOutOfBounds, "Wrong Error \(String(describing: error))")
                    
                    self.remove(safezone: safezone.id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                })
            }else{
                XCTFail()
            }

        }
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testSetSafeZoneNotFound() {
        let expect = expectation(description: "SetSafeZone")
        
        
        let safezone = SafeZone()
        
        DataManager.Instance.save(safezone, into: 0, callback: { (error) in
            
            XCTAssertNotNil(error)
            XCTAssert(error?.APIError?.errorCode == ErrorCode.SafeZoneNotFound, "Wrong Error \(String(describing: error))")
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    //MARK:- SetSafeZoneStatus
    
    func testSetSafeZoneStatusOk() {
        let expect = expectation(description: "SetSafeZoneStatus")
        
        addSafeZone { (petid, safezone) in
            
            if let id = safezone?.id {

                DataManager.Instance.setSafeZoneStatus(status: false, for: id, into: petid, callback: { (error) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetSafeZoneStatusNotFound() {
        let expect = expectation(description: "SetSafeZoneStatus")
        
        addSafeZone { (petid, safezone) in
            
            if let id = safezone?.id {

                DataManager.Instance.setSafeZoneStatus(status: false, for: 0, into: petid, callback: { (error) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.SafeZoneNotFound, "Wrong Error \(String(describing: error))")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testSetSafeZoneNotEnoughRights() {
        let expect = expectation(description: "SetSafeZoneStatus")
        
        addSafeZone { (petid, safezone) in
            
            if let id = safezone?.id {

                DataManager.Instance.setSafeZoneStatus(status: false, for: id, into: 0, callback: { (error) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error))")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    //MARK:- RemoveSafeZone
    
    func testRemoveSafeZoneOk() {
        let expect = expectation(description: "RemoveSafeZone")
        
        addSafeZone { (petid, safezone) in
            
            if let id = safezone?.id {

                DataManager.Instance.removeSafeZone(by: id, to: petid, callback: { (error) in
                    
                    XCTAssertNil(error, "Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testRemoveSafeZoneNotFound() {
        let expect = expectation(description: "RemoveSafeZone")
        
        addSafeZone { (petid, safezone) in
            
            if let id = safezone?.id {
                
                DataManager.Instance.removeSafeZone(by: 0, to: petid, callback: { (error) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.SafeZoneNotFound, "Wrong Error \(String(describing: error))")
                    
                    self.remove(safezone: id, callback: { (success) in
                        XCTAssert(success, "Not removes properly")
                        expect.fulfill()
                    })
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testRemoveSafeZoneNotEnoughRights() {
        let expect = expectation(description: "RemoveSafeZone")
        
        addSafeZone { (petid, safezone) in
            
            if let id = safezone?.id {
                
                DataManager.Instance.removeSafeZone(by: id, to: 0, callback: { (error) in
                    
                    XCTAssertNotNil(error)
                    XCTAssert(error?.APIError?.errorCode == ErrorCode.NotEnoughRights, "Wrong Error \(String(describing: error))")
                    expect.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 10) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    

}
