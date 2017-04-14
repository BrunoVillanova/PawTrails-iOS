//
//  SettingsPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol SettingsView: NSObjectProtocol, View {
    func userNotSigned()
}


class SettingsPresenter {
    
    weak private var view: SettingsView?
    
    var CountryCodes = [CountryCode]()
    
    func attachView(_ view: SettingsView){
        self.view = view
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

}
