//
//  SettingsPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol SettingsView: NSObjectProtocol, View, LoadingView {
    func userNotSigned()
    func notificationValueChangeFailed()
    func notificationValueChanged()
}

class SettingsPresenter {
    
    weak private var view: SettingsView?
    
    func attachView(_ view: SettingsView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func logout() {
        if DataManager.instance.signOut() {
            self.view?.userNotSigned()
        }else{
            self.view?.errorMessage(ErrorMsg(title:"", msg:"Couldn't Logout"))
        }
    }
    
    func changeNotification(value: Bool) {
        
        DataManager.instance.saveUserNotification(value) { (error) in
            
            if let error = error {
                self.view?.errorMessage(error.msg)
                self.view?.notificationValueChangeFailed()
            }else{
                self.view?.notificationValueChanged()
            }
        }
    }
}
