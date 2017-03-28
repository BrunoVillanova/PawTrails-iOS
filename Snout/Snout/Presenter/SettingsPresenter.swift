//
//  SettingsPresenter.swift
//  Snout
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol SettingsView: NSObjectProtocol, View {
    func loadUser(name:String?, image:Data?, sharedLocation:Bool)
    func userNotSigned()
}


class SettingsPresenter {
    
    weak private var view: SettingsView?
    
    var CountryCodes = [CountryCode]()
    
    func attachView(_ view: SettingsView){
        self.view = view
        getUser()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func logout() {
        if AuthManager.Instance.signOut() {
            self.view?.userNotSigned()
        }else{
            self.view?.errorMessage(ErrorMsg(title:"Couldn't Logout 😱", msg:""))
        }
    }
    
    func shareLocation(value:Bool) {
        //
    }
    
    fileprivate func getUser() {
        DataManager.Instance.getUser { (error, user) in
            if error != nil {
                self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
            }else if user != nil {
                DispatchQueue.main.async {
                    var name:String? = nil
                    if user!.name != nil {
                        name = user!.name!
                    }
                    if user!.name != nil && user!.surname != nil {
                        name?.append(" \(user!.surname!)")
                    }
                    self.view?.loadUser(name: name, image: nil, sharedLocation: false)
                }
            }
        }
    }

}
