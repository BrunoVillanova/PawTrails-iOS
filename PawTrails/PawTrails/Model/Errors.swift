//
//  Errors.swift
//  PawTrails
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

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
        return errorCode != nil ? Message.Instance.getMessage(from: errorCode!) : ErrorMsg(title: "", msg: "\(kind)")
    }
    
    var localizedDescription: String {
        var out = ""
        out = out.appending("Call: \(call)")
        out = out.appending(", Type: \(kind)")
        out = out.appending(", HTTPCode: \(httpCode ?? -1)")
        out = out.appending(", ErrorCode: \(errorCode ?? ErrorCode.Unknown)")
        out = out.appending(", GeneralError: \(error.debugDescription)")
        return out
    }
}

enum ErrorCode: Int {
    
    case Unknown = -1
    case NotFound = -2
    case NoConection = -3
    case WrongRequest = -4

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
    case AccountNotVerified = 29
    case SocialNetworkError = 32
    
    case PathFormat = 33
    case MissingUserId = 34
    case MissingPetId = 35
    case MissingImageFile = 36
    case IncorrectImageMime = 37
    case ImageFileSize = 38
    case UploadFailed = 39
    
    case DeviceIdNotFound = 41
    case WrongBreed = 43
    case MissingPetName = 44
    case AlreadyShared = 46
    case WeightOutOfRange = 47
    case DeviceNotAvailable = 48
    
    case NotEnoughRights = 50
    case MissingRelationUserPet = 52
    
    case MissingSafeZoneName = 53
    case WrongShapeFormat = 54
    case CoordinatesOutOfBounds = 55
    case SafeZoneNotFound = 56
    case WrongRadius = 57

    case SharedConnectionAlreadyExists = 60
    
    init(code:Int) {
        self = ErrorCode(rawValue: code) ?? ErrorCode.Unknown
    }
    
    var description: String {
        return "error \(self.rawValue):\(self)"
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

enum DatabaseError: Int {
    case NotFound = 0, IdNotFound, DuplicatedEntry, AlreadyExists, Unknown
}

enum ResponseError: Int {
    case NotFound = 0, IdNotFound, Unknown
}

struct DataManagerError: Error {
    
    let APIError: APIManagerError?
    let responseError: ResponseError?
    let DBError: DatabaseError?
    let error: Error?
    
    var localizedDescription: String {
        var out = ""
        if let errorCode = APIError?.errorCode { out = out.appending("APIError: \(errorCode)")}
        if let responseError = responseError { out = out.appending(", ResponseError: \(responseError)") }
        if let DBError = DBError { out = out.appending(", DBError: \(DBError)") }
        if let error = error { out = out.appending(", DBError: \(error.localizedDescription)") }
        return out
    }
    
    init(APIError: APIManagerError) {
        self.APIError = APIError
        self.responseError = nil
        self.DBError = nil
        self.error = nil
    }
    
    init(responseError: ResponseError) {
        self.APIError = nil
        self.responseError = responseError
        self.DBError = nil
        self.error = nil
    }
    
    init(DBError: DatabaseError) {
        self.APIError = nil
        self.responseError = nil
        self.DBError = DBError
        self.error = nil
    }
    
    init(error:Error? = nil) {
        self.APIError = nil
        self.responseError = nil
        self.DBError = nil
        self.error = error
    }
    
    init(APIError: APIManagerError?, responseError: ResponseError?, DBError: DatabaseError?, error:Error?) {
        self.APIError = APIError
        self.responseError = responseError
        self.DBError = DBError
        self.error = error
    }
    
    var msg: ErrorMsg {
        return ErrorMsg(title: "", msg: self.localizedDescription)
    }
}

enum CoreDataManagerError: Int {
    case IdNotFoundInInput = 0
    case NotSavedProperly = 1
    case ObjectNotFound  = 2
    case InternalInconsistencyException  = 3
}


enum SocketIOStatus: Int {
    case unknown = -1
    case waiting = 0
    case connected = 1
    case unauthorized = 30
    case nodevice = 31
    case timeout = 61
}
