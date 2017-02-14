//
//  APIManager.swift
//  Snout
//
//  Created by Marc Perello on 06/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias callback = (_ error:Int?, _ data:[String:Any]?) -> Void

enum call {
    case register, signin, signinsocial, signout, passwordReset, passwordChange, getuser, getpets
}

class APIManager {
    
    fileprivate static let mainURL = "http://app.liberati.name/api"
    
    static let Instance = APIManager()
    
    fileprivate func getProperties(_ call:call) -> (url:String,httpMethod:String) {
        switch call {
        case .register: return ("/users/register", "POST")
        case .signin: return ("/users/login", "POST")
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
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 10.0

        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]
        
        request.allHTTPHeaderFields = headers
        
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
            print(request)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    completition(0, nil)
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if self.isSuccess(httpResponse.statusCode) {
                        completition(nil,self.handleResults(data))
                    }else{
                        completition(self.handleError(httpResponse.statusCode, data), nil)
                    }
                }
                completition(-1, nil)

                
            }.resume()
        }
        
    }
    
    fileprivate func parseResponse(_ data:Data?) -> [String:Any]? {
        if data != nil {
            do {
                return try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
            } catch {
                print("Error -> \(error)")
                return nil
            }
        }
        return nil
    }
    
    fileprivate func handleResults(_ data:Data?) -> [String:Any]? {
        if let dict = parseResponse(data) {
            return dict["results"] as? [String:Any]
        }
        return nil
    }
    
    fileprivate func handleError(_ code: Int, _ data: Data?) -> Int? {
        
        
        if isClientError(code){
            if let dict = parseResponse(data) {
                let code = dict["errors"] as? String ?? ""
                return Int(code)
            }
            return nil
        }else{
            return code
        }
    }
    
    fileprivate func isInformational(_ code:Int) -> Bool {
        return 100...199 ~= code
    }
    
    fileprivate func isSuccess(_ code:Int) -> Bool {
        return 200...299 ~= code
    }
    
    fileprivate func isRedirection(_ code:Int) -> Bool {
        return 300...399 ~= code
    }
    
    fileprivate func isClientError(_ code:Int) -> Bool {
        return 400...499 ~= code
    }
    
    fileprivate func isServerError(_ code:Int) -> Bool {
        return 500...599 ~= code
    }
    
}

































