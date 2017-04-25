//
//  APIManager.swift
//  PawTrails
//
//  Created by Marc Perello on 06/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

public enum SocialMedia: String {
    case facebook = "FB"
    case google = "GL"
    case twitter = "TW"
    case weibo = "WB"
}

/// The APICallType enum defines constants that can be used to specify the type of interactions that take place with the APIManager requests.
public enum APICallType {
    
    case signUp, signin, facebookLogin, googleLogin, twitterLogin, weiboLogin, passwordReset, passwordChange,
    getUser, setUser, userImageUpload,
    getPets, getPet, getPetUsers, setPet, petImageUpload, dogBreeds, catBreeds, checkDevice
    
    fileprivate var requiresToken: Bool {
        switch self {
        case .signUp, .signin, .facebookLogin, .googleLogin, .twitterLogin, .weiboLogin, .passwordReset: return false
        default: return true
        }
    }
    
    fileprivate var path: String {
        switch self {
            
        case .signUp: return "/users/register"
        case .signin: return "/users/login"
        case .facebookLogin: return "/users/login/facebook"
        case .googleLogin: return "/users/login/google"
        case .twitterLogin: return "/users/login/twitter"
        case .weiboLogin: return "/users/login/weibo"
        case .passwordChange: return "/users/changepsw"
        case .passwordReset: return "/users/resetpsw"
            
        case .getUser: return "/users/\(SharedPreferences.get(.id) ?? "")"
        case .setUser: return "/users/edit"
        case .userImageUpload, .petImageUpload: return "/images/upload"
            
        case .getPets: return "/pets/"
        case .getPet: return "/pets/"
        case .getPetUsers: return "/pets/"
        case .setPet: return "/pets/"
        case .dogBreeds: return "/lists/petbreeds/\(Type.dog.rawValue)"
        case .catBreeds: return "/lists/petbreeds/\(Type.cat.rawValue)"
        case .checkDevice: return "/pets/"

//        default: return ""
        }
    }
    
    fileprivate var httpMethod: String {
        switch self {
        case .getUser, .dogBreeds, .catBreeds: return "GET"
        default: return "POST"
        }
    }
    
    fileprivate var requiresBody: Bool {
        switch self {
        case .getUser, .getPet, .dogBreeds, .catBreeds: return false
        default: return true
        }
    }
    
    init(_ SocialMedia: SocialMedia) {
        switch SocialMedia {
        case .facebook: self = .facebookLogin
        case .twitter: self = .twitterLogin
        case .google: self = .googleLogin
        case .weibo: self = .weiboLogin
        }
    }
}



/// The `APIManager` provides an infrastructure to communicate with the `RESTAPI`.
class APIManager {
    
    static let Instance = APIManager()
    
    fileprivate static let mainURL = "http://eu.pawtrails.pet/api"
    
    fileprivate let boundary = "%%%PawTrails%%%"
    
    /// Creates a `URLRequest` given the specific `APICall` and adds the information contained in `data`.
    ///
    /// - Parameters:
    ///   - call: Defines the call type.
    ///   - data: *Optional* includes the data to sent as part of the request.
    /// - Returns: URLRequest containing all the information given.
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
    
    /// Performs the request defined by the `APICallType` sending the data provided and calls a handler upon completion.
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
                    debugPrint("Error -> \(String(describing: error))")
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
    
    /// Attempts to transform the data in format `Data` into a json structure as a `dictionary`.
    ///
    /// - Parameter data: input of information.
    /// - Returns: json answer as a `dictionary`
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
            debugPrint("Output -> \(String(describing: String(data: data!, encoding: String.Encoding.utf8)))")
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
            if httpCode.isUnauthorized {
                return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode.Unauthorized)
            }else{
                let specificCode = dict["errors"] as? String ?? "-1"
                let code = Int(specificCode) ?? -1
                return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode(rawValue: code))
            }
        }
        debugPrint("No client error", call, httpCode, dict)
        return APIManagerError(call: call, kind: .noClientError, httpCode: httpCode, error: nil, errorCode: nil)
    }
    
    //MARK:- Request Helpers
    
    private func setHeaders(of call:APICallType) -> [String:String] {
        var headers = [String:String]()
        
        if call == .userImageUpload || call == .petImageUpload {
            headers["content-type"] = "multipart/form-data; boundary=\(boundary)"
        }else{
            headers["content-type"] = "application/json"
        }
        headers["cache-control"] = "no-cache"
        
        if call.requiresToken { headers["token"] = SharedPreferences.get(.token) }
        
        print(headers)
        return headers
    }
    
    private func setBody(of call:APICallType, with data:[String:Any]?) -> Data? {
        print(data ?? "No data provided to build the request body")
        if call == .userImageUpload || call == .petImageUpload {

            let boundaryStart = "--\(boundary)\r\n"
            let boundaryEnd = "--\(boundary)--\r\n"
            
            var body = Data()
            
            let mimetype = "jpg"

            
            for (key, value) in data! {
                
                if key == "picture" {
                    body.append(boundaryStart)
                    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image\"\r\n")
                    body.append("Content-Type: \(mimetype)\r\n\r\n")
                    body.append(value as! Data)
                }else{
                    body.append(boundaryStart)
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.append("\(value)")
                }
                body.append("\r\n")
            }
            body.append(boundaryEnd)
            
            print(String(data: body, encoding: .utf8) ?? "Mec")
            
            return body

            
//            print(body)
//            return body.data(using: String.Encoding.utf8)
        }else{
            return data != nil ? try? JSONSerialization.data(withJSONObject: data!, options: []) : nil
        }
    }
}

fileprivate extension Int {
    
    var isSuccess: Bool {
        return 200...299 ~= self
    }
    
    var isClientError: Bool {
        return 400...499 ~= self
    }
    
    var isUnauthorized: Bool {
        return self == 401
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

fileprivate extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

fileprivate extension Data {
    
    /// Append string to NSMutableData
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}






























