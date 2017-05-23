//
//  Messages.swift
//  PawTrails
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

//typealias errorMsg = (code: ErrorCode , title:String, msg:String)

struct ErrorMsg {
    
    let code:ErrorCode
    let title:String
    let msg:String
    
    init(title:String, msg:String) {
        self.title = title
        self.msg = msg
        code = ErrorCode.Unknown
    }
    
    init(_ _code:ErrorCode, _ _title:String, _ _msg:String) {
        code = _code
        title = _title
        msg = _msg
    }
    
}

class Message {
    
    fileprivate var language: String = "EN"
    
    static var Instance = Message()

    init(language:String = "EN") {
        self.language = language
    }
    
    enum ConnectionError: Int {
        case NoConnection = 0
        case Timeout = 1
        case ConnnectionRefused = 2
        case Unknown = 3
    }

    func connectionError(type:ConnectionError) -> String {
        switch type {
        case .ConnnectionRefused: return lm("Connection Refused")
        case .Timeout: return lm("Connection Timeout")
        case .NoConnection: return lm("No Connection")
        case .Unknown: return lm("Unknown Connection Error")
        }
    }
    
    func getMessage(from code:ErrorCode) -> ErrorMsg {
        let title = lm("Error")
//        switch code {
//            
//        case .Unauthorized: return ErrorMsg(code, title, lm("User Not Authorized"))
//        case .MissingEmail: return ErrorMsg(code, title, lm("Missing email"))
//        case .EmailFormat: return ErrorMsg(code, title, lm("Incorrect email format"))
//        case .MissingPassword: return ErrorMsg(code, title, lm("Missing password"))
//        case .WeakPassword: return ErrorMsg(code, title, lm("Weak password"))
//        case .UserAlreadyExists: return ErrorMsg(code, title, lm("The user already exists"))
//        case .UserDisabled: return ErrorMsg(code, title, lm("Disabled User"))
//
//            
//        case .AccountNotVerified: return ErrorMsg(code, title, lm("Account not verified"))
//        case .UserNotFound: return ErrorMsg(code, title, lm("User not found"))
//        case .WrongCredentials: return ErrorMsg(code, title, lm("Wrong password"))
//        case .WrongPassword: return ErrorMsg(code, title, lm("Wrong password"))
//            
//        default: return ErrorMsg(ErrorCode.Unknown, title, lm("Unknown error"))
//        }
        
        return ErrorMsg(code, title, "\(code)")
    }
    
    func authError(type:AuthenticationError) -> ErrorMsg {
        let title = lm("Authentication Error")
        switch type {
            
        case .EmptyUserResponse: return ErrorMsg(ErrorCode.Unknown, title, lm("Empty User Response"))
        case .EmptyUserTokenResponse: return ErrorMsg(ErrorCode.Unknown, title, lm("Empty UserToken Response"))
        case .EmptyUserAppIdResponse: return ErrorMsg(ErrorCode.Unknown, title, lm("Empty AppId Response"))
        case .EmptyUserIdResponse: return ErrorMsg(ErrorCode.Unknown, title, lm("Empty UserId Response"))
            
        case .UserNotFound: return ErrorMsg(ErrorCode.Unknown, title, lm("User not found"))
        case .WrongCredentials: return ErrorMsg(ErrorCode.Unknown, title, lm("The credentials provided are incorrect."))
        case .Unknown: return ErrorMsg(ErrorCode.Unknown, title, lm("Unknown Error"))
        default: return ErrorMsg(ErrorCode.Unknown, "", "")
        }
    }
    
    func softwareDevelopmentError(_ whatever:[String:Any]?) -> ErrorMsg {
        return ErrorMsg(ErrorCode.Unknown, "Development Error", "\(String(describing: whatever))")
    }
    
   
    private func lm(_ input:String) -> String {
        return input
    }
    
    
    
}
