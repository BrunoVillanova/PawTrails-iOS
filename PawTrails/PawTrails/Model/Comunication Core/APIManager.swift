//
//  APIManager.swift
//  PawTrails
//
//  Created by Marc Perello on 06/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SystemConfiguration
import SwiftyJSON

/// The APICallType enum defines constants that can be used to specify the type of interactions that take place with the APIManager requests.
public enum APICallType {
    
    case signUp, signIn, facebookLogin, googleLogin, twitterLogin, weiboLogin, passwordReset, passwordChange,
    getUser, setUser, imageUpload, friends, deleteUser,
    registerPet, getPets, getPet, setPet, checkDevice, changeDevice, unregisterPet,
    getPetClasses, getBreeds, getContinents, getCountries,
    sharePet, getSharedPetUsers, removeSharedPet,leaveSharedPet,
    addSafeZone, setSafeZone, getSafeZone, listSafeZones, removeSafeZone, startTrip, finishTrip, pauseTrip, resumeTrip, getTripList, getTripsAchievements, editDailyGoal, getDailyGoals, activityMonitor
    
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
        case .deleteUser: return "/deleteUser/\(key)"
            
        case .getUser: return "/users/\(key)"
        case .setUser: return "/users/edit"
        case .imageUpload: return "/images/upload"
        case .friends: return "/users/my/friendslist"
            
        case .registerPet: return "/pets/register"
        case .getPets: return "/pets/my/list"
        case .getPet: return "/pets/\(key)"
        case .setPet: return "/pets/\(key)/edit"
        case .checkDevice: return "/pets/devices/checkCode"
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
        case .startTrip: return "/trips/start"
        case .finishTrip: return "/trips/stop"
        case .pauseTrip: return "/trips/pause"
        case .resumeTrip: return "/trips/resume"
        case .getTripList: return "/trips/list"
        case .getTripsAchievements: return "/trips/achievementsget"
        case .editDailyGoal: return "/pets/dailygoalsedit"
        case .getDailyGoals: return "/pets/dailygoalsget"
        case .activityMonitor: return "/activity/load"
        }
    }
    
    /// Defines the HTTP Method Protocol: GET, POST...
    fileprivate var httpMethod: String {
        switch self {
    case .getUser, .deleteUser, .getPetClasses, .getBreeds, .getCountries, .getContinents, .getPets, .getPet, .getSharedPetUsers, .unregisterPet, .leaveSharedPet, .friends, .getSafeZone, .listSafeZones, .removeSafeZone, .resumeTrip : return "GET"
        default: return "POST"
        }
    }
    
    fileprivate var requiresBody: Bool {
        return self.httpMethod == "POST"
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
    
    static let instance = APIManager()
    
    fileprivate static let mainURL = Constants.apiURL
    fileprivate static let mainURLTest = Constants.apiURLTest

    fileprivate let boundary = "%%%PawTrails%%%"
    
    /// Creates a `URLRequest` given the specific `APICall` and adds the information contained in `data`.
    ///
    /// - Parameters:
    ///   - call: Defines the call type.
    ///   - data: *Optional* includes the data to sent as part of the request.
    /// - Returns: URLRequest containing all the information given.
    private func createRequest(for call:APICallType, with key:Any, and data:[String:Any]?) -> URLRequest? {
        
        if call.requiresBody && data == nil {
            Reporter.send(file: "\(#file)", function: "\(#function)", APIManagerError(call: call, kind: APIManagerError.errorKind.requestError, httpCode: nil, error: nil, errorCode: ErrorCode.WrongRequest), ["Description":"The call requires body but it does not have it!"])
        }
        
        var request = URLRequest(url: URL(call, with: key))
        
        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", request)
        
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
    ///   - key: *Optional* contributes to build the url.
    ///   - data: *Optional* includes the data sent as part of the request.
    ///   - callback: Handles callback
    ///   - error: An error object that indicates why the request failed, or `nil` if the request was successful.
    ///   - data: The data returned or `nil` if error.
    func perform(call:APICallType, withKey key:Any = "", with data:[String:Any]? = nil, callback: @escaping (_ error:APIManagerError?,_ data:JSON?) -> Void) {
        
        if isConnectedToNetwork() == true {
        
            if let request = createRequest(for: call, with: key, and: data) {
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            let error = APIManagerError(call: call, kind: .requestError, httpCode:nil, error: error, errorCode:nil)
                            Reporter.send(file: "\(#file)", function: "\(#function)", error)
                            callback(error, nil)
                        }else{
                            guard let httpResponse = response as? HTTPURLResponse else {
                                callback(APIManagerError(call: call, kind: .httpResponseParse, httpCode: nil, error:nil, errorCode:nil), nil)
                                return
                            }
                            self.handleResponse(for: call, httpResponse.statusCode, data, callback)
                        }
                    }
                }
                task.resume()
                
            }else {
                callback(APIManagerError(call: call, kind: .requestError, httpCode: nil, error: nil, errorCode: ErrorCode.WrongRequest), nil)
            }
        }else{
            callback(APIManagerError(call: call, kind: .requestError, httpCode: nil, error: nil, errorCode: ErrorCode.NoConection), nil)
        }
        
    }
    
    /// Attempts to transform the data in format `Data` into a json structure as a `dictionary`.
    ///
    /// - Parameter data: input of information.
    /// - Returns: `JSON` Object
    private func parseResponse(_ data:Data?) -> JSON {
        
        if let data = data {
            if let json =  try? JSON(data: data) {
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", json.dictionaryObject ?? "")
                return json
            }
        }
        
        return JSON(parseJSON: "")
    }
    
    private func handleResponse(for call: APICallType, _ code: Int, _ data: Data?, _ callback: @escaping (_ error:APIManagerError?, _ data:JSON?) -> Void ) {
        if code.isSuccess {
            callback(nil, parseResponse(data))
        }else{
            let error = handleError(call, code, data)
            Reporter.send(file: "\(#file)", function: "\(#function)", error)
            callback(error, nil)
        }
    }
    
    private func handleError(_ call: APICallType, _ httpCode: Int, _ data: Data?) -> APIManagerError {
        
        if httpCode.isUnauthorized {
            return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode.Unauthorized)
        
        }else if httpCode.isNotFound {
            return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode.NotFound)
        }else {
            
            if httpCode.isClientError {
                
                guard let data = data else {
                    return APIManagerError(call: call, kind: .httpResponseParse, httpCode:nil, error:nil, errorCode:nil)
                }
                let jsonObject = parseResponse(data)

                let code = jsonObject.dictionaryObject?.tryCastInteger(for: "errors") ?? -1
                return APIManagerError(call: call, kind: .clientError, httpCode: httpCode, error: nil, errorCode: ErrorCode(rawValue: code))

            }else{
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
            let token = SharedPreferences.get(.token)
            if token != "" { headers["token"] = token }
            else {
                Reporter.send(file: "\(#file)", function: "\(#function)", APIManagerError(call: call, kind: APIManagerError.errorKind.requestError, httpCode: nil, error: nil, errorCode: ErrorCode.MissingToken))
            }
        }
        
        return headers
    }
    
    private func setBody(of call:APICallType, with data:[String:Any]?) -> Data? {
        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "REQUEST BODY", data ?? "No data provided to build the request body")
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
            return body
        }else{
            return data != nil ? try? JSONSerialization.data(withJSONObject: data!, options: []) : nil
        }
    }
    
    private func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress , {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
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
        if call == .deleteUser {
            guard let url = URL(string: APIManager.mainURL + call.path(with: key)) else{
                fatalError("Couldn't build URL \(call) \(APIManager.mainURL)")
            }
            self = url
        }else{
            guard let url = URL(string: APIManager.mainURL + call.path(with: key)) else{
                fatalError("Couldn't build URL \(call) \(APIManager.mainURL)")
            }
            self = url
        }
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






























