//
//  Constants.swift
//  PawTrails
//
//  Created by Marc Perello on 14/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

#if DEMO
let isBetaDemo = true
#else
let isBetaDemo = false
#endif

public struct ezdebug {
    public static let email = "ios@test.com"
    public static let password = "iOStest12345"
    public static let is4test = "mohamed@attitudetech.ie"
}

struct Constants {
    
    // Image Max Size
    
    static let maxImageSize = 2 * 1024 * 1024 // In Bytes 2MB
    static let maxWeight = 9999.999
    
    // Safe Zone
    
    static let minimumDistance = 50.0
    
    static let apiURLProduction = "https://eu.pawtrails.com/api"
    static let apiURLTestProduction = "https://eu.pawtrails.com/test"
    static let socketURLProduction = "http://eu.pawtrails.com:2003"
    static let socketURLSSLProduction = "https://eu.pawtrails.com:4654"

    static let apiURLStaging = "https://alpha.pawtrails.com/api"
    static let apiURLTestStaging = "https://alpha.pawtrails.com/test"
    static let socketURLStaging = "http://alpha.pawtrails.com:2003"
    static let socketURLSSLStaging = "https://alpha.pawtrails.com:4654"

    static let testUserEmailProduction = "attitudetech2017@gmail.com"
    static let testUserPasswordProduction = "ABCd1234"
    static let testUserEmailStaging = "ios@test.com"
    static let testUserPasswordStaging = "iOStest12345"
    static let testUserEmailProductionDemo = "trails@pawtrails.ie"
    static let testUserPasswordProductionDemo = "Trails123!"
    
    static let deviceIdforDemo = "RcpWfA9PGGYz"
    
    /////////// BEGIN apiURL
    #if DEBUG
    static let apiURL = apiURLStaging
    static let apiURLTest = apiURLTestStaging
    static let socketURL = socketURLStaging
    static let socketURLSSL = socketURLSSLStaging
    #else

    #if DEMO
    static let apiURL = apiURLStaging
    static let apiURLTest = apiURLTestStaging
    static let socketURL = socketURLStaging
    static let socketURLSSL = socketURLSSLStaging
    #else
    static let apiURL = apiURLProduction
    static let apiURLTest = apiURLTestProduction
    static let socketURL = socketURLProduction
    static let socketURLSSL = socketURLSSLProduction
    #endif

    #endif
    /////////// END apiURL

//    ////////// FORCE PRODUCTION
//    static let apiURL = apiURLProduction
//    static let apiURLTest = apiURLTestProduction
//    static let socketURL = socketURLProduction
//    static let socketURLSSL = socketURLSSLProduction
    
    static var testUserEmail: String {
        get {
            if apiURL == apiURLProduction {
                return testUserEmailProduction
            }
            #if DEMO
                return testUserEmailProductionDemo
            #else
            #if BETA
                return testUserEmailProduction
            #else
                return testUserEmailStaging
            #endif
            #endif
        }
    }
    
    static var testUserPassword: String {
        get {
            if apiURL == apiURLProduction {
                return testUserPasswordProduction
            }
            #if DEMO
                return testUserPasswordProductionDemo
            #else
            #if BETA
            return testUserPasswordProduction
            #else
            return testUserPasswordStaging
            #endif
            #endif
        }
    }
    
    
}
