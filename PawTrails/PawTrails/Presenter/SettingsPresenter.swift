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
        if AuthManager.Instance.signOut() {
            self.view?.userNotSigned()
        }else{
            self.view?.errorMessage(ErrorMsg(title:"", msg:"Couldn't Logout"))
        }
    }
    
    func changeNotification(value: Bool) {
        
        var data = [String:Any]()
        data["id"] = SharedPreferences.get(.id)
        data["notification"] = value
        
        DataManager.Instance.save(user: data) { (error, user) in
            DispatchQueue.main.async {
                
                if let error = error {
                    self.view?.errorMessage(error.msg)
                    self.view?.notificationValueChangeFailed()
                }else{
                    self.view?.notificationValueChanged()
                }
            }
        }
    }
}
