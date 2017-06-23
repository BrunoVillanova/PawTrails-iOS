//
//  UserProfilePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 31/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol UserProfileView: NSObjectProtocol, View {
    func load(user:User)
    func userNotSigned()
}


class UserProfilePresenter {
    
    weak private var view: UserProfileView?
    
    
    var user:User!
    
    func attachView(_ view: UserProfileView){
        self.view = view
        getUser()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getUser() {
        DataManager.Instance.getUser { (error, user) in
            DispatchQueue.main.async {
                if let error = error {
                    self.view?.errorMessage(error.msg)
                }else if let user = user {
                    self.user = user
                    self.view?.load(user:user)
                }
            }
        }
    }
    
    func loadUser() {
        DataManager.Instance.loadUser { (error, user) in
            DispatchQueue.main.async {
                if let error = error {
                    self.view?.errorMessage(error.msg)
                }else if let user = user {
                    self.user = user
                    self.view?.load(user:user)
                }
            }
        }
    }
}
