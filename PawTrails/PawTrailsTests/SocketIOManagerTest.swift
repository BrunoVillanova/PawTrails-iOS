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
    
    override func setUp(){
        SocketIOManager.Instance.closeConnection()
    }
    
    func testConnection() {
        
        let expect = expectation(description: "Connection")
        let clock = Clock()
        SocketIOManager.Instance.establishConnection { 
            expect.fulfill()
            clock.stop()
            debugPrint(clock.elapsedSeconds)
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
    
}
