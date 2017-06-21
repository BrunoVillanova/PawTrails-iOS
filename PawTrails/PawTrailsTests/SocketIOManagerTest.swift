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
    
    func testConnectionTimer() {
        SocketIOManager.Instance.disconnect()
        let expect = expectation(description: "Connection")
        let clock = Clock()
        SocketIOManager.Instance.connect({ (error) in
            XCTAssertNil(error, String(describing: error))
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
        
        SocketIOManager.Instance.connect({ (error) in
            XCTAssertNil(error, String(describing: error))
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
                XCTAssert(error == .timeout, String(describing: error))
                SharedPreferences.set(.token, with: token)
                expect.fulfill()
            })
        }
        
        waitForExpectations(timeout: 100) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
}






















































