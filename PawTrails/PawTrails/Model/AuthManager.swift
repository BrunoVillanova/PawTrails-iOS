//
//  ModelManager.swift
//  PawTrails
//
//  Created by Marc Perello on 02/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin

typealias errorCallback = (_ error:DataManagerError?) -> Void

class AuthManager {
    
    static let Instance = AuthManager()


    func isAuthenticated() -> Bool {
       return SharedPreferences.has(.id) && SharedPreferences.has(.token)
    }
    
    func socialMedia() -> String? {
        return SharedPreferences.get(.socialnetwork) 
    }
    
    func signUp(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signUp, with: data) { (error, data) in
            if let error = error {
                completition(self.handleAuthErrors(error, data))
            }else if let data = data {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    func signIn(_ email:String, _ password: String, completition: @escaping errorCallback) {
        let data = isDebug ? ["email":email, "password":password, "is4test":ezdebug.is4test] : ["email":email, "password":password]
        APIManager.Instance.perform(call: .signIn, with: data) { (error, data) in
            if let error = error {
                completition(self.handleAuthErrors(error))
            }else if let data = data {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    func login(socialMedia: SocialMedia, _ token: String, completition: @escaping errorCallback){
        var data = [String:Any]()
        data["loginToken"] = token
        if socialMedia == .google { data["itsIOS"] = 1 }
        APIManager.Instance.perform(call: APICallType(socialMedia), with: data) { (error, data) in
            if let error = error {
                completition(self.handleAuthErrors(error))
            }else if let data = data {
                self.succeedLoginOrRegister(data, completition: completition)
            }
        }
    }
    
    fileprivate func succeedLoginOrRegister(_ data:[String:Any], completition: @escaping errorCallback){
        
        guard let token = data["token"] as? String else {
            completition(DataManagerError.init(responseError: ResponseError.NotFound))
            return
        }
        guard let userData = data["user"] as? [String:Any] else {
            completition(DataManagerError.init(responseError: ResponseError.NotFound))
            return
        }
        guard let userId = userData["id"] as? String else {
            completition(DataManagerError.init(responseError: ResponseError.NotFound))
            return
        }
        if let socialNetwork = data["social_network"] as? String {
            SharedPreferences.set(.socialnetwork, with: socialNetwork)
        }
        if let socialNetworkId = data["social_network_id"] as? String {
            SharedPreferences.set(.socialnetworkId, with: socialNetworkId)
        }
        SharedPreferences.set(.token, with: token)
        SharedPreferences.set(.id, with: userId)
        
        var errors = [DataManagerError]()
        let queue = DispatchQueue(label: "ErrorQueue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        let tasks = DispatchGroup()
        
        tasks.enter()
        DataManager.Instance.setUser(userData) { (error, user) in
            if let error = error {
                queue.async {
                    errors.append(error)
                }
            }
            tasks.leave()
        }
        
        tasks.enter()
        DataManager.Instance.loadPets(callback: { (error, pets) in
            if let error = error {
                queue.async {
                    errors.append(error)
                }
            }
            tasks.leave()
        })
        
        _ = DataManager.Instance.getCountryCodes()
        
        tasks.notify(queue: .main) { 
            
            queue.sync {
                if errors.count == 0 {
                    DispatchQueue.main.async {
                        completition(nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        for error in errors {
                            debugPrint(error.localizedDescription)
                        }
                        completition(errors.first)
                    }
                }
            }
            
        }
    }
    
    func signOut() -> Bool {
        //wipe out DB

        CoreDataManager.Instance.deleteAll()
//        if let socialMedia = AuthManager.Instance.socialMedia() {
//            if let sm = SocialMedia(rawValue: socialMedia) {
//                switch sm {
//                case .facebook:
//                    let loginManager = LoginManager()
//                    loginManager.logOut()
////                case .twitter:
////                    Fabric.with([Twitter.self])
//                case .google:
//                    GIDSignIn.sharedInstance().signOut()
//                default:
//                    break
//                }
//            }
//        }

//        GIDSignIn.sharedInstance().signOut()
        return SharedPreferences.remove(.id) && SharedPreferences.remove(.token)
    }
    
    func sendPasswordReset(_ email:String, completition: @escaping errorCallback) {
        let data = isDebug ? ["email":email, "is4test":ezdebug.is4test] : ["email":email]

        APIManager.Instance.perform(call: .passwordReset, with: data) { (error, data) in
            if let error = error {
                completition(self.handleAuthErrors(error))
            }else{
                completition(nil)
            }
        }
    }
    
    func changeUsersPassword(_ email:String, _ password:String, _ newPassword:String, completition: @escaping errorCallback) {
        let data = ["id": SharedPreferences.get(.id) ?? "", "email":email, "password":password, "new_password":newPassword]
        APIManager.Instance.perform(call: .passwordChange, with: data) { (error, data) in
            if let error = error {
                completition(self.handleAuthErrors(error))
            }else{
                completition(nil)
            }
        }
    }
    
    fileprivate func handleAuthErrors(_ error: APIManagerError, _ data: [String:Any]? = nil) -> DataManagerError? {
        return DataManagerError(APIError: error)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
