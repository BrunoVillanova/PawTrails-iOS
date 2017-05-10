//
//  PetUsersPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 19/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PetUsersView: NSObjectProtocol, View {
    func usersNotFound()
    func loadUsers()
    func userRemoved()
}


class PetUsersPresenter {
    
    weak private var view: PetUsersView?
    
    var users = [_petUser]()
    
    func attachView(_ view: PetUsersView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func removeUser(by userId:String, of petId: String) {
        
        if let currentUserId = SharedPreferences.get(.id) {
            
            var data = [String: Any]()
            data["user_id"] = userId
            
            if userId == currentUserId {
                DataManager.Instance.removeSharedUser(by: data, to: petId, callback: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            debugPrint(error)
                            self.view?.errorMessage(ErrorMsg(title: "", msg: "\(error)"))
                        }else{
                            self.view?.userRemoved()
                        }
                    }
                })
                
                
                
            }else{
                DataManager.Instance.leaveSharedPet(by: petId, callback: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            debugPrint(error)
                            self.view?.errorMessage(ErrorMsg(title: "", msg: "\(error)"))
                        }else{
                            self.view?.userRemoved()
                        }
                    }
                })
            }
        }
    }
}
