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
    case MissingToken = -5

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
    case NoGpsFromPet = 31
    
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
    case ThereIsApetWithAnActiveTrip = 71
    case TheTripIsPaused = 72
    case TheIdInTheInputArrayMustBeAnInteger = 76
    case RequiredPetSize = 99

    init(code:Int) {
       self = ErrorCode(rawValue: code) ?? ErrorCode.Unknown
   }
    var description: String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .NotFound:
            return "Not Found"

        case .NoConection:
            return "Not Internet connection"

        case .WrongRequest:
            return "Unknown request"

        case .MissingToken:
            return ""

        case .Unauthorized:
            return ""
        case .MissingEmail:
            return "This account doesn't exsist."
        case .EmailFormat:
            return "Email format is wrong."
        case .MissingPassword:
            return "Please enter a password"
        case .WeakPassword:
            return "Weak Passsword (Needs to contain 6 characters, one upper case, one lower case and one number)"
        case .UserAlreadyExists:
            return "Another account is already using this email. "
        case .UserDisabled:
            return "Account Disabled, Please Contact Us."

        case .DateOfBirth:
            return "Error. Please try again later"

        case .GenderFormat:
            return "Error. Please try again later"
        case .PhoneFormat:
            return "Error. Please try again later"
        case .UserNotFound:
            return "Error. Please try again later"
        case .WrongPassword:
            return "Incorrect password. "
        case .WrongCredentials:
            return "Incorrect email or password"
        case .TooManyRequests:
            return "You've tried to reset too many times, please try again in 5 minutes."

        case .WrongOTP:
            return "You've tried to reset too many times, please try again in 5 minutes."
        case .PasswordUnmatch:
            return "Passwords don't match, please try again"

        case .OTPnotFound:
            return "This link has expired."

        case .OTPexpired:
            return "This link has expired."

        case .AccountNotVerified:
            return "Your account is not verified, please check your email to verify your account"

        case .SocialNetworkError:
            return "Error connecting to your social media account."
        case .NoGpsFromPet:
            return "No Gps updates from your pet"

        case .PathFormat:
            return "Error. Please try again later"

        case .MissingUserId:
            return "Error. Please try again later"

        case .MissingPetId:
            return "Error. Please try again later"

        case .MissingImageFile:
            return "Error. Please try again later"

        case .IncorrectImageMime:
            return "Error. Please try again later"

        case .ImageFileSize:
            return "The image is too big , the picture size limit is 2MB."
        case .UploadFailed:
            return "Error. Please try again later"

        case .DeviceIdNotFound:
            return "This device ID is not available."
        case .WrongBreed:
            return "Error, Please try again later"

        case .MissingPetName:
            return "Pet's name is mandatory."
        case .AlreadyShared:
            return "The pet is already shared with this user"

        case .WeightOutOfRange:
            return "This weight size is unavailable."
        case .DeviceNotAvailable:
            return "This device is already used by different user"

        case .NotEnoughRights:
            return "You have no permissions to proceed with your request"

        case .MissingRelationUserPet:
            return "Error. Please try again later"

        case .MissingSafeZoneName:
            return "Safe Zone name is mandatory."
        case .WrongShapeFormat:
            return "Error. Please try again later"

        case .CoordinatesOutOfBounds:
            return "Error. Please try again later"

        case .SafeZoneNotFound:
            return "Error. Please try again later"

        case .WrongRadius:
            return "Safe Zone radius is too small."
        case .SharedConnectionAlreadyExists:
            return "This user already has access to this pet. "

        case .ThereIsApetWithAnActiveTrip:
            return "The pet/pets already is in a trip with anoter user"

        case .TheTripIsPaused:
            return "Error. Please try again later"

        case .TheIdInTheInputArrayMustBeAnInteger:
            return "Error. Please try again later"

        case .RequiredPetSize:
            return "Pet size is required"
        
        }
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

struct DatabaseError: Error {
    var type: DatabaseErrorType
    var entity: Entity?
    var action: DatabaseErrorAction
    var error: NSError?
    
    var localizedDescription: String {
        return "\(action) \(String(describing: entity)) \(type)"
    }
}

enum DatabaseErrorAction {
    case upsert, get, remove, save, store
}

enum DatabaseErrorType: Int {
    case NotFound = 0, IdNotFound, DuplicatedEntry, AlreadyExists, Unknown, NotSavedProperly, ObjectNotFound, InternalInconsistencyException

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
        if (APIError?.call) != nil { out = out.appending("")}
        if let errorCode = APIError?.errorCode?.description { out = out.appending("\(errorCode)")}
        if let responseError = responseError { out = out.appending("\(responseError)") }
        if let DBError = DBError { out = out.appending("\(DBError.localizedDescription)") }
        if let error = error { out = out.appending("\(error.localizedDescription)") }
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


enum SocketIOStatus: Int {
    case unknown = -1
    case waiting = 0
    case connected = 1
    case unauthorized = 30
    case unauthorized2 = 419
    case nodevice = 31
    case timeout = 61
}
