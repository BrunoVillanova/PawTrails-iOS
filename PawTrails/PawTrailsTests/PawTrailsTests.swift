//
//  SnoutTests.swift
//  SnoutTests
//
//  Created by Marc Perello on 16/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import XCTest
@testable import PawTrails

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
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "cc8b46c7-1b28-f9a0-048a-7225b5c1be97"
        ]
        let parameters = [
            "email": "iosV2@test.com",
            "is4test": "marc@attitudetech.ie"
            ] as [String : Any]
        
        let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://eu.pawtrails.pet/api/users/resetpsw")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData! as Data
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        }
        
        task.resume()
    }
    
    func testUsers() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        if let users = CoreDataManager.Instance.retrieve("User") as? [User]{
            for i in users {
                print(i.id ?? "nil id")
                NSLog("%@", i)
            }
        }
    }
    
    
}
