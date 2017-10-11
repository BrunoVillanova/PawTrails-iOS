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
        SocketIOManager.instance.disconnect()
    }
    
    //MARK:- Connection
    
    func testConnectionTimer() {

        let expect = expectation(description: "Connection")
        let clock = Clock()
        SocketIOManager.instance.connect({ (status) in
            XCTAssert(status == SocketIOStatus.connected, String(describing: status))
            expect.fulfill()
            clock.stop()
            Reporter.debug(clock.elapsedSeconds)
        })
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testConnectionOk() {
        
        let expect = expectation(description: "Connection")
        
        SocketIOManager.instance.connect({ (status) in
            XCTAssert(status == SocketIOStatus.connected, String(describing: status))
            expect.fulfill()
        })
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
    func testConnectionUnauthorized() {
        
        let expect = expectation(description: "Connection")
        
        let token = SharedPreferences.get(.token)
        if token != "" {
            
            SharedPreferences.set(.token, with: "")
            
            SocketIOManager.instance.connect({ (error) in
                
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
        

        NotificationManager.instance.getPetGPSUpdates(for: 25) { (id, data) in
            XCTAssertNotNil(id, String(describing: id))
            XCTAssertNotNil(data, String(describing: data))

            Reporter.debug(id, data.debugDescription)
            SocketIOManager.instance.stopGPSUpdates(for: id)
            NotificationManager.instance.removePetGPSUpdates(of: 25)
            expect.fulfill()
        }
        SocketIOManager.instance.startGPSUpdates(for: [24,25])
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }

    
}






















































