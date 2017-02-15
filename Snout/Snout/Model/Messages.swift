//
//  Messages.swift
//  Snout
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias errorMsg = (title:String, msg:String)

//struct errorMsg {
//    let title:String
//    let msg:String
//}

class Message {
    
    
    fileprivate var language: String = "EN"
    
    static var Instance = Message()
//    
//    init(language:String) {
//        self.language = language
//    }
    
    func connectionError(type:ConnectionError) -> String {
        switch type {
        case .ConnnectionRefused: return lm("Connection Refused")
        case .Timeout: return lm("Connection Timeout")
        case .NoConnection: return lm("No Connection")
        case .Unknown: return lm("Unknown Connection Error")
        }
    }
    
    func authError(type:AuthenticationError) -> errorMsg {
        let title = lm("Authentication Error")
        switch type {

        case .MissingEmail: return (title, lm("Missing email"))
        case .EmailFormat: return (title, lm("The email provided has a wrong format"))
        case .MissingPassword: return (title, lm("Missing password"))
        case .WeakPassword: return (title, lm("The password provided is too weak"))
        case .UserAlreadyExists: return (title, lm("The user already exists"))
        case .UserDisabled: return (title, lm("This user has been disabled"))
            
            
        case .EmptyUserResponse: return (title, lm("Empty User Response"))
        case .EmptyUserTokenResponse: return (title, lm("Empty UserToken Response"))
        case .EmptyUserIdResponse: return (title, lm("Empty UserId Response"))
            
        case .UserNotFound: return (title, lm("User not found"))
        case .WrongCredentials: return (title, lm("The credentials provided are incorrect."))
        case .Unknown: return (title, lm("Unknown Error"))
        }
    }
    
    func softwareDevelopmentError(_ whatever:[String:Any]?) -> errorMsg {
        return ("Development Error", "\(whatever)")
    }
    
    private func err(_ title:String, _ msg:String) -> errorMsg {
        return errorMsg(lm(title), lm(msg))
    }
    
    private func lm(_ input:String) -> String {
        return input
    }
    
    
    
}
