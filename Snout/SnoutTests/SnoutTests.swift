//
//  SnoutTests.swift
//  SnoutTests
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import Snout

class SnoutTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testMapper() {
        var address = [String:Any]()
        address["line0"] = ""
        address["line1"] = ""
        address["city"] = ""
        address["state_county"] = ""
        address["country"] = ""
        
        var user = [String:Any]()
        user["id"] = 9
        user["email"] = "enjoy"
        user["address"] = address
        
        do {
            let a = try User(user)
            print(a.print())
        } catch {
            print(error)
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
