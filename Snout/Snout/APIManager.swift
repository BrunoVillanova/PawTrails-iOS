//
//  APIManager.swift
//  Snout
//
//  Created by Marc Perello on 06/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias callback = (_ error:Error?, _ data:[String:Any]?) -> Void

enum call {
    case register, signin, signinsocial, signout, getuser, getpets
}

class APIManager {
    
    fileprivate static let mainURL = ""
    
    static let Instance = APIManager()
    
    fileprivate func getProperties(_ call:call) -> (url:String,httpMethod:String) {
        switch call {
        case .register: return ("/register/", "POST")
        case .signin: return ("/signin/", "POST")
        default: return ("/register/", "POST")
        }
    }
    
    fileprivate func requiresHeaderToken(_ call:call) -> Bool {
        switch call {
        case .register, .signin, .signinsocial: return false
        default: return true
        }
    }
    
    fileprivate func createRequest(_ call:call, _ data:[String:Any]?) -> URLRequest? {
        
        let properties = getProperties(call)
        
        let url = APIManager.mainURL + properties.url
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = properties.httpMethod
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        if data != nil {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!) else {
                // raise error
                return nil
            }
            request.httpBody = jsonData
        }
        
        if requiresHeaderToken(call) {
            request.setValue("", forHTTPHeaderField: "token")
        }
        
        return request
    }
    
    func performCall(_ call:call, _ data:[String:Any]? = nil, completition: @escaping callback) {
        
        if let request = createRequest(call, data) {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    completition(error, nil)
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                    
                    print("Result -> \(result)")
                    completition(error, result)
                    
                } catch {
                    print("Error -> \(error)")
                    completition(error, nil)
                }
            }.resume()
        }
        
    }
    
}

































