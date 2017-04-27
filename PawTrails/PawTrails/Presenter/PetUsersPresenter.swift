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
}


class PetUsersPresenter {
    
    weak private var view: PetUsersView?
    
    var users = [_petUser]()
    
    func attachView(_ view: PetUsersView){
        self.view = view
        getUsers()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getUsers() {
//        DataManager.Instance.getPetUsers(0, callback: { (error, users) in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
//                }else if let users = users {
//                    self.users = users
//                    self.view?.loadUsers()
//                }
//            }
//            
//        })
    }
    
}
