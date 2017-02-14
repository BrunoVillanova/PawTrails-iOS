//
//  Errors.swift
//  Snout
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

enum ConnectionError: Int {
    case NoConnection = 0
    case Timeout = 1
    case ConnnectionRefused = 2
    case Unknown = 3
}

enum ServerError: Int {
    case InternalError = 500
    case NotImplemented = 501
    case ServiceUnavailable = 503
    case HttpVersionNotsupported = 505
}


enum AuthenticationError: Int {
    case MissingEmail = 10
    case EmailFormat  = 11
    case MissingPassword  = 12
    case WeakPassword = 13
    case UserAlreadyExists = 14
    case UserDisabled = 15
    
    case UserNotFound  = 6
    case WrongCredentials = 8
    case EmptyUserResponse = 7
    case EmptyUserTokenResponse = 5
    case EmptyUserIdResponse = 4
    case Unknown = 9
}

enum UserError: Int {
    case IdNotFound = 10
    case UserNotFound = 11
    case MoreThenOneUser  = 12
    case NoUserFound  = 13
}


enum CoreDataManagerError: Int {
    case IdNotFoundInInput = 0
    case NotSavedProperly = 1
    case ObjectNotFound  = 2
    case InternalInconsistencyException  = 3
}


