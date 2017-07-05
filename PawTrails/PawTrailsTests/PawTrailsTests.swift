//
//  PawTrailsTests.swift
//  PawTrailsTests
//
//  Created by Marc Perello on 14/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

class PawTrailsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        

        let expect = expectation(description: "Test example")
        let id = SharedPreferences.get(.id)
        if id != "" {
            _ = SharedPreferences.remove(.id)
            
            DataManager.instance.loadPetFriends { (error, friends) in
                
                XCTAssertNil(friends)
                XCTAssertNotNil(error)
                XCTAssert(error?.DBError == DatabaseError.IdNotFound, "Error \(String(describing: error))")
                SharedPreferences.set(.id, with: id)
                
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "waitForExpectationsWithTimeout errored: \(String(describing: error))")
        }
    }
}
