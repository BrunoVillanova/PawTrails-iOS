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
            self.view?.errorMessage(errorMsg(title:"Couldn't Logout 😱", msg:""))
        }
    }
    
    func shareLocation(value:Bool) {
        //
    }
    
    fileprivate func getUser() {
        DataManager.Instance.getUser { (error, user) in
            if error != nil {
                self.view?.errorMessage(errorMsg("","\(error)"))
            }else if user != nil {
                DispatchQueue.main.async {
                    self.view?.loadUser(name: user?.name, image: nil, sharedLocation: false)
                }
            }
        }
    }

}
