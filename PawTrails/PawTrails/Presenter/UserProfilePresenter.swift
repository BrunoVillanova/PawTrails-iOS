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
    
    var CountryCodes = [CountryCode]()
    
    func attachView(_ view: UserProfileView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getUser() {
        DataManager.Instance.getUser { (error, user) in
            DispatchQueue.main.async {
                if error != nil {
                    self.view?.errorMessage(ErrorMsg(title: "",msg: "\(String(describing: error))"))
                }else if user != nil {
                    self.view?.load(user:user!)
                }
            }
        }
    }
    
}
