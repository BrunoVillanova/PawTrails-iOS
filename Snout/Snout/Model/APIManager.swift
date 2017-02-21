//
//  APIManager.swift
//  Snout
//
//  Created by Marc Perello on 06/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

/**
 The `APIManager` provides an infrastructure to communicate with the `REST API`.
 */
class APIManager {
    
    /**
     Contains the constants used to specify the interaction with the `APIManager`.
     */
    enum call {
        case register, signin, signinsocial, signout, passwordReset, passwordChange, getuser, setuser , getpets
        
        var requiresToken: Bool {
            switch self {
            case .register, .signin, .signinsocial: return false
            default: return true
            }
        }
        
        fileprivate var url: String {
            switch self {
            case .register: return "/users/register"
            case .signin: return "/users/login"
            case .passwordChange: return "/users/changepsw"
            case .setuser: return "/users/edit"
            default: return ""
            }
        }
        
        fileprivate var httpMethod: String {
            return "POST"
        }
    }
    
    private static let mainURL = "http://app.liberati.name/api"
    
    static let Instance = APIManager()
    
    private func setHeaders(_ call:call) -> [String:String] {
        var headers = [
            "content-type": "application/json",
            "cache-control": "no-cache"
        ]
        if call.requiresToken {
            headers["token"] = SharedPreferences.get(.token)
            headers["appid"] = SharedPreferences.get(.appId)
        }
        return headers
    }
    
    private func setBody(with data:[String:Any]?) -> Data? {
        print(data ?? "no data provided to build the request body")
        return data != nil ? try? JSONSerialization.data(withJSONObject: data!) : nil
    }
    
    private func createRequest(_ call:call, _ data:[String:Any]?) -> URLRequest? {
        
        
        let url = APIManager.mainURL + call.url
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = call.httpMethod
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 10.0
        
        request.allHTTPHeaderFields = setHeaders(call)
        print(request.allHTTPHeaderFields ?? "")
        request.httpBody = setBody(with: data!)
        return request
    }
    
    /**
     Performs a call to the REST API.
     
     - Parameter call: Defines the request.
     - Parameter data: *Optional* includes the data sent as part of the request.
     - Parameter completition: Performs the callback once the response is ready.
     - Parameter error: An error object that indicates why the request failed, or `nil` if the request was successful.
     - Parameter data: The data returned or `nil` if error.
     
     */
    func performCall(_ call:call, _ data:[String:Any]? = nil, completition: @escaping (_ error:APIManagerError?, _ data:[String:Any]?) -> Void) {
        
        if let request = createRequest(call, data) {
            print(request)
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                
                if error != nil{
                    print("Error -> \(error)")
                    completition(APIManagerError(call: call, httpCode: -1, specificCode: -1, kind: .requestError), nil)
                }else{
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completition(APIManagerError(call: call, httpCode: -1, specificCode: -1, kind: .httpResponseParse), nil)
                        return
                    }
                    self.handleResponse(call, httpResponse.statusCode, data, completition)
                }
            }.resume()
        }
        
    }
    
    private func parseResponse(_ data:Data?) -> [String:Any]? {
        if data != nil {
            do {
                let out = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] 
                print(out ?? "couldn't parse json!")
                return out
//                return try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
            } catch {
                print("Error -> \(error)")
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "not convertible to string either")
                return nil
            }
        }
        return nil
    }
    
    private func handleResponse(_ call: call, _ code: Int, _ data: Data?, _ completition: @escaping (_ error:APIManagerError?, _ data:[String:Any]?) -> Void ) {
        if code.isSuccess {
            completition(nil, parseResponse(data))
        }else{
            completition(handleError(call, code, data), nil)
        }
    }
    
    private func handleError(_ call: call, _ code: Int, _ data: Data?) -> APIManagerError? {
        
        if code.isClientError {
            guard let dict = parseResponse(data) else {
                return APIManagerError(call: call, httpCode: code, specificCode: -1, kind: .jsonParse)
            }
            let specificCode = dict["errors"] as? String ?? "-2"
            return APIManagerError(call: call, httpCode: code, specificCode: Int(specificCode)!, kind: .handleError)
        }
        return APIManagerError(call: call, httpCode: code, specificCode: -1, kind: .handleError)
    }
}

fileprivate extension Int {
    
    var isSuccess: Bool {
        return 200...299 ~= self
    }
    
    var isClientError: Bool {
        return 400...499 ~= self
    }
    
}
































