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
        self.view?.beginLoadingContent()
        
        var data = [String:Any]()
        data["id"] = SharedPreferences.get(.id)
        data["notification"] = value
        
        DataManager.Instance.setUser(data) { (error, user) in
            DispatchQueue.main.async {
                self.view?.endLoadingContent()
                if let error = error {
                    self.view?.errorMessage(error.msg)
                    self.view?.notificationValueChangeFailed()
                }
            }
        }
    }
}
