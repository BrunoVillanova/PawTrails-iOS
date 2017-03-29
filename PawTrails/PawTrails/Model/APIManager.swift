//
//  APIManager.swift
//  Snout
//
//  Created by Marc Perello on 06/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

/// The APICallType enum defines constants that can be used to specify the type of interactions that take place with the APIManager requests.
public enum APICallType {
    
    case signUp, signin, signinsocial, passwordReset, passwordChange, getUser, setUser , getPet, setPet, trackPet
    
    fileprivate var requiresToken: Bool {
        switch self {
        case .signUp, .signin, .signinsocial, .passwordReset: return false
        default: return true
        }
    }
    
    fileprivate var path: String {
        switch self {
        case .signUp: return "/users/register"
        case .signin: return "/users/login"
        case .passwordChange: return "/users/changepsw"
        case .passwordReset: return "/users/resetpsw"
        case .setUser: return "/users/edit"
        case .getUser: return "/users/\(SharedPreferences.get(.id) ?? "")"
        default: return ""
        }
    }
    
    fileprivate var httpMethod: String {
        return self == .getUser ? "GET" : "POST"
    }
    
    fileprivate var requiresBody: Bool {
        switch self {
        case .getUser, .getPet: return false
        default: return true
        }
    }
}



/// The `APIManager` provides an infrastructure to communicate with the `RESTAPI`.
class APIManager {
    
    static let Instance = APIManager()
    
    fileprivate static let mainURL = "http://eu.pawtrails.pet/api"
    
    private func createRequest(for call:APICallType, with data:[String:Any]?) -> URLRequest? {
        
        if call.requiresBody && data == nil {
            debugPrint("\(call) requires body")
            return nil
        }
        
        var request = URLRequest(url: URL(call))
        
        debugPrint(request)
        
        request.httpMethod = call.httpMethod
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 10.0
        
        request.allHTTPHeaderFields = setHeaders(of: call)
        request.httpBody = setBody(of: call, with: data)
        
        return request
    }
    
    /// Performs the request defined by the `APICallType` sending the data provided and and calls a handler upon completion.
    ///
    /// - Parameters:
    ///   - call: The [APICallType](APIManager) defines the request.
    ///   - data: *Optional* includes the data sent as part of the request.
    ///   - completition: Handles callback
    ///   - error: An error object that indicates why the request failed, or `nil` if the request was successful.
    ///   - data: The data returned or `nil` if error.
    func perform(call:APICallType, with data:[String:Any]? = nil, completition: @escaping (_ error:APIManagerError?,_ data:[String:Any]?) -> Void) {
        
        if let request = createRequest(for: call, with: data) {

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if error != nil{
                    debugPrint("Error -> \(error)")
                    completition(APIManagerError(call: call, kind: .requestError, httpCode:nil, error: error, errorCode:nil), nil)
                }else{
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completition(APIManagerError(call: call, kind: .httpResponseParse, httpCode: nil, error:nil, errorCode:nil), nil)
                        return
                    }
                    self.handleResponse(for: call, httpResponse.statusCode, data, completition)
                }
            }
            
            task.resume()
        }
        
    }
    
    private func parseResponse(_ data:Data?) -> [String:Any]? {
        
        if data == nil { return nil }
        
        do {
            if let out = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] {
                debugPrint(out)
                return out
            }else if let rs = String(data: data!, encoding: String.Encoding.utf8) {
                debugPrint(rs)
                return ["no_JSON_RS":rs]
            }else{
                debugPrint("couldn't parse to string")
                return nil
            }
            
        } catch {
            debugPrint("Error parsing to json -> \(error)")
            debugPrint("Output -> \(String(data: data!, encoding: String.Encoding.utf8))")
            return nil
        }
    }
    
    private func handleResponse(for call: APICallType, _ code: Int, _ data: Data?, _ completition: @escaping (_ error:APIManagerError?, _ data:[String:Any]?) -> Void ) {
        if code.isSuccess {
            completition(nil, parseResponse(data))
        }else{
            completition(handleError(call, code, data), nil)
        }
    }
    
    private func handleError(_ call: APICallType, _ httpCode: Int, _ data: Data?) -> APIManagerError? {
        
        guard let dict = parseResponse(data) else {
            return APIManagerError(call: call, kind: .jsonParse, httpCode:nil, error:nil, errorCode:nil)
        }
        
        if httpCode.isClientError {
            let specificCode = dict["errors"] as? String ?? "-1"
            let code = Int(specificCode) ?? -1
            return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode(rawValue: code))
        }
        debugPrint("No client error", call, httpCode, dict)
        return APIManagerError(call: call, kind: .noClientError, httpCode: httpCode, error: nil, errorCode: nil)
    }
    
    //MARK:- Request Helpers
    
    private func setHeaders(of call:APICallType) -> [String:String] {
        var headers = [String:String]()
        headers["content-type"] = "application/json"
        headers["cache-control"] = "no-cache"
        
        if call.requiresToken {
            headers["token"] = SharedPreferences.get(.token)
        }
        print(headers)
        return headers
    }
    
    private func setBody(of call:APICallType, with data:[String:Any]?) -> Data? {
        print(data ?? "No data provided to build the request body")
        return data != nil ? try? JSONSerialization.data(withJSONObject: data!, options: []) : nil
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

fileprivate extension URL {
    
    init(_ call: APICallType) {
        guard let url = URL(string: APIManager.mainURL + call.path) else{
            fatalError("Couldn't build URL \(call) \(APIManager.mainURL)")
        }
        self = url
    }
}

































