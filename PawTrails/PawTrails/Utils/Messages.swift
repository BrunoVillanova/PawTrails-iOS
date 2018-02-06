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
    let msg: String
    
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
    
    static var instance = Message()

    init(language:String = "EN") {
        self.language = language
    }
    
    
    // System messages
    
    enum systemMessage {
        case passwordRequirements, forgotPassword, newSharedUserEmailRequirements, unknown
    }
    
    func get(_ sm: systemMessage) -> String {
        switch sm {
        case .passwordRequirements: return lm("The password must have at least 8 characters including uppercase letters, lowercase letters and numbers.")
        case .forgotPassword: return lm("Forgot Password?")
        case .newSharedUserEmailRequirements: return lm("The email must belong to a registered user in the Pawtrails System")
        default: return lm("")
        }
    }
    
    func get(_ st: GPSStatus) -> String {
        switch st {
        case .idle: return "Perfect"
        case .noDeviceFound: return "No device found"
        case .disconected: return "Device Disconnected"
        case .unknown: return "-"
        }
    }
    
   
    private func lm(_ input:String) -> String {
        return input
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
