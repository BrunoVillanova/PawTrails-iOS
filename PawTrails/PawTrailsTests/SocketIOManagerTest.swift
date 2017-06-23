//
//  DataManagerTest.swift
//  PawTrails
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class SocketIOManagerTest: XCTestCase {
    
    override func setUp() {
        SocketIOManager.Instance.disconnect()
    }
    
    //MARK:- Connection
    
    func testConnectionTimer() {

        let expect = expectation(description: "Connection")
        let clock = Clock()
        SocketIOManager.Instance.connect({ (status) in
            XCTAssert(status == SocketIOStatus.connected, String(describing: status))
            expect.fulfill()
            clock.stop()
            debugPrint(clock.elapsedSeconds)
        })
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testConnectionOk() {
        
        let expect = expectation(description: "Connection")
        
        SocketIOManager.Instance.connect({ (status) in
            XCTAssert(status == SocketIOStatus.connected, String(describing: status))
            expect.fulfill()
        })
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testConnectionUnauthorized() {
        
        let expect = expectation(description: "Connection")
        
        if let token = SharedPreferences.get(.token) {
            
            SharedPreferences.set(.token, with: "")
            
            SocketIOManager.Instance.connect({ (error) in
                
                XCTAssertNotNil(error, String(describing: error))
                XCTAssert(error == .unauthorized, String(describing: error))
                SharedPreferences.set(.token, with: token)
                expect.fulfill()
            })
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    //MARK:- GPSUpdates
    
    func testGPSUpdates(){
        
        let expect = expectation(description: "GPSUpdates")
        

        NotificationManager.Instance.getPetGPSUpdates(for: 25) { (id, data) in
            XCTAssertNotNil(id, String(describing: id))
            XCTAssertNotNil(data, String(describing: data))

            debugPrint(id, data.debugDescription)
            SocketIOManager.Instance.stopGPSUpdates(for: id)
            NotificationManager.Instance.removePetGPSUpdates(of: 25)
            expect.fulfill()
        }
        SocketIOManager.Instance.startGPSUpdates(for: [24,25])
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }

    
}






















































