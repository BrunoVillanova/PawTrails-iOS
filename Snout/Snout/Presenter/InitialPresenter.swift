//
//  InitialPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol InitialView: NSObjectProtocol {
    func errorMessage(_ error:String)
    func userCreated()
}

class InitialPresenter {
    
    weak fileprivate var initialView: InitialView?
    
    func attachView(_ view: InitialView){
        self.initialView = view
    }
    
    func deteachView() {
        self.initialView = nil
    }
    
    func register(email:String, password:String) {
        FBAuthManagement.Instance.register(email, password) { (error) in
            if error != nil {
                self.initialView?.errorMessage(error!)
            }else{
                self.initialView?.userCreated()
            }
        }
    }
    
}
