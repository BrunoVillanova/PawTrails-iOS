//
//  Messages.swift
//  Snout
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

typealias errorMsg = (title:String, msg:String)

class Message {
    
    
    fileprivate var language: String = "EN"
    
    static var Instance = Message()
//    
//    init(language:String) {
//        self.language = language
//    }
    
    func connectionError(type:ConnectionError) -> errorMsg {
        let title = lm("Connection Error")
        switch type {
        case .ConnnectionRefused: return (title, lm("Refused"))
        case .Timeout: return (title, lm("Timeout"))
        case .NoConnection: return (title, lm("Lost Connection"))
        case .Unknown: return (title, lm("Unknown Error"))
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
    
    
    fileprivate func lm(_ input:String) -> String {
        return input
    }
    
}
