//
//  FBAuthManagement.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import Firebase

class FBAuthManagement {
    
    static let Instance = FBAuthManagement()
    
    func isSignedIn() -> Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
    
    func register(_ email:String, _ password: String, completition: @escaping (_ error:String?) -> Void) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            completition(self.handleAuthErrors(error: error))
        }
    }
    
    func signIn(_ email:String, _ password: String, completition: @escaping (_ error:String?) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            completition(self.handleAuthErrors(error: error))
        }
    }
    
    func signOut(completition: ((_ error:String?) -> Void)?) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            completition!(nil)
        } catch let error as NSError {
            completition!(self.handleAuthErrors(error: error))
        } catch {
            completition!("Unspecified error for signout")
        }
    }
    
    func sendVerificationEmail(completition: @escaping (_ error:String?) -> Void) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
            completition(self.handleAuthErrors(error: error))
        })
    }
    
    func sendPasswordReset(_ email:String, completition: @escaping (_ error:String?) -> Void) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
            completition(self.handleAuthErrors(error: error))
        }
    }
    
    func setUsersPassword(_ email:String, _ password:String, _ newPassword:String, completition: @escaping (_ error:String?) -> Void) {
        
        let _email = FIRAuth.auth()?.currentUser?.email
        
        if _email == nil || _email != email {
            completition("The email introduced is not correct!")
        }else{
            
            self.signIn(email, password, completition: { (error) in
                if error != nil {
                    completition(self.handleAuthErrors(error: error))
                }else{
                    FIRAuth.auth()?.currentUser?.updatePassword(newPassword) { (error) in
                        completition(self.handleAuthErrors(error: error))
                    }
                }
            })
        }
    }
    
    fileprivate func handleAuthErrors(error: Any?) -> String? {
        if let e = error as? NSError {
            return e.localizedDescription
        }
        return nil
    }
    
}
