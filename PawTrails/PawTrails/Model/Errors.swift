//
//  Errors.swift
//  PawTrails
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


//enum ServerError: Int {
//    case InternalError = 500
//    case NotImplemented = 501
//    case ServiceUnavailable = 503
//    case HttpVersionNotsupported = 505
//}

struct APIManagerError: Error {
    
    enum errorKind {
        case requestError
        case httpResponseParse
        case jsonParse
        case clientError
        case noClientError
    }

    let call: APICallType
    let kind: errorKind
    let httpCode: Int?
    let error:Error?
    let errorCode: ErrorCode?
    
    func info() -> ErrorMsg? {
        return errorCode != nil ? Message.Instance.getMessage(from: errorCode!) : nil
    }
}

enum ErrorCode: Int {
    
    case Unknown = -1
    case Unauthorized = 0
    case MissingEmail = 10
    case EmailFormat = 11
    case MissingPassword = 12
    case WeakPassword = 13
    case UserAlreadyExists = 14
    case UserDisabled = 15
    case DateOfBirth = 16
    case GenderFormat = 17
    case PhoneFormat = 18
    case UserNotFound = 19
    case WrongPassword = 20
    case WrongCredentials = 21
    case TooManyRequests = 23
    case WrongOTP = 24
    case PasswordUnmatch = 25
    case OTPnotFound = 26
    case OTPexpired = 27
    case SQLBadFormat = 28
    case AccountNotVerified = 29
    
    init(code:Int) {
        self = ErrorCode(rawValue: code) ?? ErrorCode.Unknown
    }

}

enum AuthenticationError: Int {
    
    case MissingEmail = 10, EmailFormat, MissingPassword, WeakPassword, UserAlreadyExists, UserDisabled,
    DateOfBirth, GenderFormat, PhoneFormat, UserNotFound, WrongPassword, WrongCredentials
    
    case EmptyUserResponse = 0
    case EmptyUserTokenResponse = 1
    case EmptyUserAppIdResponse = 2
    case EmptyUserIdResponse = 3
    case Unknown = -1
}

enum UserError: Int {
    case UserNotFoundInDataBase = 8
    case UserNotFoundInResponse = 9
    case IdNotFound = 10
    case UserNotFound = 11
    case MoreThenOneUser  = 12
    case NotAuthenticated = 14
}

enum PetError: Int {
    case PetNotFoundInDataBase = 8
    case PetNotFoundInResponse = 9
    case IdNotFound = 10
    case MoreThenOnePet  = 12
    case NotAuthenticated = 14
}

enum BreedError: Int {
    case BreedNotFoundInDataBase = 8
//    case PetNotFoundInResponse = 9
//    case IdNotFound = 10
//    case MoreThenOnePet  = 12
//    case NotAuthenticated = 14
}


enum CoreDataManagerError: Int {
    case IdNotFoundInInput = 0
    case NotSavedProperly = 1
    case ObjectNotFound  = 2
    case InternalInconsistencyException  = 3
}


