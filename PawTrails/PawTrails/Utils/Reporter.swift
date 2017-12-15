//
//  Reporter.swift
//  PawTrails
//
//  Created by Marc Perello on 03/07/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import Crashlytics


class Reporter {
    
    static func debugPrint(file: String, function: String, _ items: Any...){
//        let itemsDescription = items.map({ String(describing: $0) }).joined(separator: ",")
//        NSLog("\(file.components(separatedBy: "/").last ?? "") - \(function): \(itemsDescription)")
    }
    
    static func log(_ string: String){
//        CLSLogv(string)
    }
    
    static func send(file: String, function: String, _ error: Error, _ userInfo: [String:Any]? = nil){
        var userInfo = userInfo ?? [String:Any]()
        userInfo["File"] = file
        userInfo["Fucntion"] = function
        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: userInfo)
    }
    
    static func setUser(name: String?, email: String?, id: String?){
        Crashlytics.sharedInstance().setUserName(name)
        Crashlytics.sharedInstance().setUserEmail(email)
        Crashlytics.sharedInstance().setUserIdentifier(id)
    }
}
