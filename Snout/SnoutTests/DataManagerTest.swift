//
//  DataManagerTest.swift
//  Snout
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import Snout

class DataManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCountryCodes() {

//        for i in CountryCodeManager.getAll()! {
//            print(i.code! + " " + i.name!)
//        }
//    
//        if let c = CountryCodeManager.get("970") {
//            print(c.name)
//        }
        if let users = CoreDataManager.Instance.retrieve(entity: "User") as? [User] {
            for i in users {
                NSLog("%@", i)
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
