//
//  APIManager.swift
//  PawTrails
//
//  Created by Marc Perello on 06/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum SocialMedia: String {
    case facebook = "FB"
    case google = "GL"
    case twitter = "TW"
    case weibo = "WB"
}

/// The APICallType enum defines constants that can be used to specify the type of interactions that take place with the APIManager requests.
public enum APICallType {
    
    case signUp, signIn, facebookLogin, googleLogin, twitterLogin, weiboLogin, passwordReset, passwordChange,
    getUser, setUser, imageUpload, friends, deleteUser,
    registerPet, getPets, getPet, setPet, checkDevice, changeDevice, unregisterPet,
    getPetClasses, getBreeds, getContinents, getCountries,
    sharePet, getSharedPetUsers, removeSharedPet,leaveSharedPet,
    addSafeZone, setSafeZone, getSafeZone, listSafeZones, removeSafeZone
    
    /// Defines APICallType need of token
    fileprivate var requiresToken: Bool {
        switch self {
        case .signUp, .signIn, .facebookLogin, .googleLogin, .twitterLogin, .weiboLogin, .passwordReset: return false
        default: return true
        }
    }
    
    /// APICallType path
    ///
    /// - Parameter key: *optional* it helps to build the path
    /// - Returns: the url path for the specific APICallType
    fileprivate func path(with key: Any) -> String {
        switch self {
            
        case .signUp: return "/users/register"
        case .signIn: return "/users/login"
        case .facebookLogin: return "/users/login/facebook"
        case .googleLogin: return "/users/login/google"
        case .twitterLogin: return "/users/login/twitter"
        case .weiboLogin: return "/users/login/weibo"
        case .passwordChange: return "/users/changepsw"
        case .passwordReset: return "/users/resetpsw"
        case .deleteUser: return "/test/deleteUser/\(key)"
            
        case .getUser: return "/users/\(key)"
        case .setUser: return "/users/edit"
        case .imageUpload: return "/images/upload"
        case .friends: return "/users/my/friendslist"
            
        case .registerPet: return "/pets/register"
        case .getPets: return "/pets/my/list"
        case .getPet: return "/pets/\(key)"
        case .setPet: return "/pets/\(key)/edit"
        case .checkDevice: return "/pets/devices/\(key)/checkCode"
        case .changeDevice: return "/pets/\(key)/devicechange"
        case .unregisterPet: return "/pets/\(key)/remove"

        case .getPetClasses: return "/lists/petclasses"
        case .getBreeds: return "/lists/petbreeds/\(key)"
        case .getContinents: return "/lists/continents"
        case .getCountries: return "/lists/countries"

        case .sharePet: return "/pets/share/\(key)/add"
        case .getSharedPetUsers: return "/pets/share/\(key)/userslist"
        case .removeSharedPet: return "/pets/share/\(key)/del"
        case .leaveSharedPet: return "/pets/share/\(key)/leave"
            
        case .addSafeZone: return "/pets/safezones/add"
        case .setSafeZone: return "/pets/safezones/mod"
        case .getSafeZone: return "/pets/safezones/view/\(key)"
        case .removeSafeZone: return "/pets/safezones/del/\(key)"
        case .listSafeZones: return "/pets/safezones/list/\(key)"

//        default: return ""
        }
    }
    
    fileprivate var httpMethod: String {
        switch self {
        case .getUser, .deleteUser, .getPetClasses, .getBreeds, .getCountries, .getContinents, .checkDevice, .getPets, .getPet, .getSharedPetUsers, .unregisterPet, .leaveSharedPet, .friends, .getSafeZone, .listSafeZones, .removeSafeZone : return "GET"
        default: return "POST"
        }
    }
    
    fileprivate var requiresBody: Bool {
        switch self {
        case .getUser, .deleteUser, .getPetClasses, .getBreeds, .getCountries, .getContinents, .checkDevice, .getPets, .getPet, .getSharedPetUsers, .unregisterPet, .leaveSharedPet, .friends, .getSafeZone, .listSafeZones, .removeSafeZone : return false
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
    private func createRequest(for call:APICallType, with key:Any, and data:[String:Any]?) -> URLRequest? {
        
        if call.requiresBody && data == nil {
            fatalError("\(call) requires body")
        }
        
        var request = URLRequest(url: URL(call, with: key))
        
//        debugPrint(request)
        
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
    func perform(call:APICallType, withKey key:Any = "", with data:[String:Any]? = nil, completition: @escaping (_ error:APIManagerError?,_ data:[String:Any]?) -> Void) {
        
        if isConnectedToNetwork() {
        
            if let request = createRequest(for: call, with: key, and: data) {
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if let error = error {
                        debugPrint("Error -> \( error)")
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
                
            }else {
                completition(APIManagerError(call: call, kind: .requestError, httpCode: nil, error: nil, errorCode: ErrorCode.WrongRequest), nil)
            }
        }else{
            completition(APIManagerError(call: call, kind: .requestError, httpCode: nil, error: nil, errorCode: ErrorCode.NoConection), nil)
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
                debugPrint("JSON RS", out)
                return out
            }else if let rs = String(data: data!, encoding: String.Encoding.utf8) {
                debugPrint("STRING RS", rs)
                return nil
            }else{
                debugPrint("couldn't parse to string")
                return nil
            }
            
        } catch {
            debugPrint("Error parsing to json -> \(error)","Output -> \(String(describing: String(data: data!, encoding: String.Encoding.utf8)))")
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
        
        debugPrint(call, httpCode, data ?? "no data")
        if httpCode.isUnauthorized {
            return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode.Unauthorized)
        
        }else if httpCode.isNotFound {
            return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode.NotFound)
        }else {
            
            if httpCode.isClientError {
                
                guard let dict = parseResponse(data) else {
                    return APIManagerError(call: call, kind: .jsonParse, httpCode:nil, error:nil, errorCode:nil)
                }
                
                let code = dict.tryCastInteger(for: "errors") ?? -1
                return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode(code: code))
                
            }else if let data = data {
                debugPrint("No client error", call, httpCode, String(data: data, encoding: String.Encoding.utf8) ?? "couldn't cast response to string")
                return APIManagerError(call: call, kind: .noClientError, httpCode: httpCode, error: nil, errorCode: nil)
            }else{
                debugPrint("No client error", call, httpCode, "empty response")
                return APIManagerError(call: call, kind: .noClientError, httpCode: httpCode, error: nil, errorCode: nil)
            }
        }
    }
    
    //MARK:- Request Helpers
    
    private func setHeaders(of call:APICallType) -> [String:String] {
        var headers = [String:String]()
        
        if call == .imageUpload {
            headers["content-type"] = "multipart/form-data; boundary=\(boundary)"
        }else{
            headers["content-type"] = "application/json"
        }
        headers["cache-control"] = "no-cache"
        
        if call.requiresToken  {
            if let token = SharedPreferences.get(.token) { headers["token"] = token }
            else { debugPrint("missing token for \(call)") }
        }
        
//        debugPrint(headers)
        return headers
    }
    
    private func setBody(of call:APICallType, with data:[String:Any]?) -> Data? {
//        debugPrint("REQUEST BODY", data ?? "No data provided to build the request body")
        if call == .imageUpload {

            let boundaryStart = "--\(boundary)\r\n"
            let boundaryEnd = "--\(boundary)--\r\n"
            
            var body = Data()
            
            let mimetype = "image/jpg"

            
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
            
//            debugPrint(String(data: body, encoding: .utf8) ?? "Mec")
            
            return body
        }else{
            return data != nil ? try? JSONSerialization.data(withJSONObject: data!, options: []) : nil
        }
    }
    
    private func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
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
    
    var isNotFound: Bool {
        return self == 404
    }
}

fileprivate extension URL {
    
    init(_ call: APICallType, with key: Any) {
        guard let url = URL(string: APIManager.mainURL + call.path(with: key)) else{
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






























