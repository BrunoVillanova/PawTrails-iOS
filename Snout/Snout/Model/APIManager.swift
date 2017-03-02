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
        case register, signin, signinsocial, passwordReset, passwordChange, getuser, setuser , getpets
        
        fileprivate var requiresToken: Bool {
            switch self {
            case .register, .signin, .signinsocial: return false
            default: return true
            }
        }
        
        fileprivate func url() -> String {
            switch self {
            case .register: return "/users/register"
            case .signin: return "/users/login"
            case .passwordChange: return "/users/changepsw"
            case .setuser: return "/users/edit"
            case .getuser: return "/users/\(SharedPreferences.get(.id) ?? "")"
            default: return ""
            }
        }
        
        fileprivate var httpMethod: String {
            return self == .getuser ? "GET" : "POST"
        }
    }
    
    fileprivate static let mainURL = "http://eu.pawtrails.pet/api"
    
    static let Instance = APIManager()
    
    
    private func createRequest(_ call:call, _ data:[String:Any]?) -> URLRequest? {
        
        var request = URLRequest(url: getURL(call))
        
        request.httpMethod = call.httpMethod
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 10.0
        
        request.allHTTPHeaderFields = setHeaders(call)
        request.httpBody = setBody(of: call, with: data)
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
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "not convertible to string either")
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
    
    //MARK:- Request Helpers
    
    private func getURL(_ call:call) -> URL {
        guard let url = URL(string: APIManager.mainURL + call.url()) else{
            fatalError("Couldn't build URL \(call) \(APIManager.mainURL)")
        }
        print(url)
        return url
    }
    
    private func setHeaders(_ call:call) -> [String:String] {
        var headers = [String:String]()
        headers["content-type"] = "application/json"
        headers["cache-control"] = "no-cache"
        
        if call.requiresToken {
            headers["token"] = SharedPreferences.get(.token)
        }
        print(headers)
        return headers
    }
    
    private func setBody(of call:call, with data:[String:Any]?) -> Data? {
        print(data ?? "No data provided to build the request body")
        return data != nil ? try? JSONSerialization.data(withJSONObject: data!) : nil
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

































