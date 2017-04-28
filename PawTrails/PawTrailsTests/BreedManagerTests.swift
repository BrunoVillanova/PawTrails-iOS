//
//  BreedManagerTests.swift
//  PawTrails
//
//  Created by Marc Perello on 25/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails


class BreedManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testExample() {
//        
//        let expect = expectation(description: "get breeds")
//        
//        APIManagerTests().signIn { (id, token) in
//            
//            SharedPreferences.set(.id, with: id)
//            SharedPreferences.set(.token, with: token)
//            
//            //            let type = Type.dog
//            let type = Type.cat
//            
//            BreedManager.get(for: type) { (error, breeds) in
//                
//                if error == nil, let breeds = breeds {
//                    
//                    BreedManager.retrieve(for: type, callback: { (error, savedBreeds) in
//                        
//                        if error == nil, let savedBreeds = savedBreeds {
//                            if savedBreeds.count != breeds.count {
//                                XCTFail("Breeds not saved properly \(String(describing: savedBreeds.count)) found \(String(describing: breeds)) expected")
//                            }else{
//                                for b in breeds {
//                                    if !savedBreeds.contains(b) {
//                                        XCTFail("Not found \(String(describing: b)) in \(String(describing: savedBreeds)) expected")
//                                    }
//                                }
//                                expect.fulfill()
//                            }
//                        }else{
//                            XCTFail("Error get breeds \(String(describing: error)) \(String(describing: breeds))")
//                        }
//                        
//                    })
//                }else{
//                    XCTFail("Error get breeds \(String(describing: error)) \(String(describing: breeds))")
//                }
//                
//            }
//        }
//        
//        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
//        
//    }
    
    func testCatBreeds() {
        
        let expect = expectation(description: "get cat breeds")
        
        loadBreeds(for: .cat) { (success) in
            assert(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func testDogBreeds() {
        
        let expect = expectation(description: "get dog breeds")
        
        loadBreeds(for: .dog) { (success) in
            assert(success)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
        
    }
    
    func loadBreeds(for type:Type, callback: @escaping ((Bool)->())) {
        
        APIManagerTests().signIn { (id, token) in
            
            SharedPreferences.set(.id, with: id)
            SharedPreferences.set(.token, with: token)
            
            BreedManager.load(for: type) { (error, breeds) in
                
                if error == nil && breeds != nil {
                    callback(true)
                }else{
                    print("Error get breeds \(String(describing: error)) \(String(describing: breeds))")
                    callback(false)
                }
                
            }
        }
    }
    
    func testRemove() {
        
        
        let expect = expectation(description: "remove breeds")
        
//        BreedManager.remove(for: .cat)
//        
//        BreedManager.retrieve(for: .cat) { (error, breeds) in
//            assert(breeds == nil, "Enjoy")
//            print(breeds ?? "")
////            expect.fulfill()
//        }
        
        
        BreedManager.remove(for: .dog)
        
        BreedManager.retrieve(for: .dog) { (error, breeds) in
            assert(breeds == nil, "Enjoy")
            print(breeds ?? "")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1000) { error in if error != nil { XCTFail("waitForExpectationsWithTimeout errored: \(String(describing: error))") } }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }




















































}
