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

struct APIManagerError: Error {
    
    enum errorKind {
        case httpResponseParse
        case jsonParse
        case requestError
        case handleError
    }

    let call: APICallType
    let httpCode: Int
    let specificCode: Int
    let kind: errorKind?
}


enum AuthenticationError: Int {
    case MissingEmail = 10, EmailFormat, MissingPassword, WeakPassword, UserAlreadyExists, UserDisabled, DateOfBirth, GenderFormat, PhoneFormat, UserNotFound, WrongPassword, WrongCredentials

    case EmptyUserResponse = 0
    case EmptyUserTokenResponse = 1
    case EmptyUserAppIdResponse = 2
    case EmptyUserIdResponse = 3
    case Unknown = -1
}

enum UserError: Int {
    case IdNotFound = 10
    case UserNotFound = 11
    case MoreThenOneUser  = 12
    case NoUserFound  = 13
    case NotAuthenticated = 14
}


enum CoreDataManagerError: Int {
    case IdNotFoundInInput = 0
    case NotSavedProperly = 1
    case ObjectNotFound  = 2
    case InternalInconsistencyException  = 3
}


