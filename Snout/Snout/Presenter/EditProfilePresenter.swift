//
//  EditProfilePresenter.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol EditProfileView: NSObjectProtocol, View {
    func emailFormat()
    func loadData(user:User)
    func saved()
}

class EditProfilePresenter {
    
    weak fileprivate var view: EditProfileView?
    
    func attachView(_ view: EditProfileView){
        self.view = view
        getUser()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    fileprivate func getUser() {
        DataManager.Instance.getUser { (error, user) in
            if error != nil {
                self.view?.errorMessage(errorMsg("","\(error)"))
            }else if user != nil {
               self.view?.loadData(user: user!)
            }
        }
    }
    
    func save(name:String?, surname:String?, email:String?, gender:String?) {
        var data = [String:Any]()
        data["id"] = SharedPreferences.get(.id)
        data["name"] = name ?? ""
        data["surname"] = surname ?? ""
        data["email"] = email ?? ""
        if gender != nil && gender != "undefined" {
            data["gender"] = gender! == "female" ? "F" : "M"
        }
        
        APIManager.Instance.performCall(.setuser, data) { (error, data) in
            if error == nil && data != nil {
                self.view?.saved()
            }else{
                print(error ?? "")
                print(data ?? "")
            }
        }
     }
    
}

