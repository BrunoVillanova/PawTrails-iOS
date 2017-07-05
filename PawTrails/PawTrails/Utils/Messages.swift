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
    
    static var instance = Message()

    init(language:String = "EN") {
        self.language = language
    }
    
    
    // System messages
    
    enum systemMessage {
        case passwordRequirements, forgotPassword, unknown
    }
    
    func get(_ sm: systemMessage) -> String {
        switch sm {
        case .passwordRequirements: return lm("The password must have at least 8 characters including uppercase letters, lowercase letters and numbers.")
        case .forgotPassword: return lm("Forgot Password?")
        default: return lm("")
        }
    }
    
   
    private func lm(_ input:String) -> String {
        return input
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
