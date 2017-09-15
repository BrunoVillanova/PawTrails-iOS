//
//  UserProfileView.swift
//  PawTrails
//
//  Created by Marc Perello on 14/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


protocol ProfileView: NSObjectProtocol, View {
    func loadUsers()
    func petNotFound()
    func removed()

}


class UserView {
    
    weak private var view: ProfileView?
    var users = [PetUser]()
    
    
    func attachView(_ view: ProfileView) {
        self.view = view
    }
    
    
    func deteachView() {
        self.view = nil
    }
    

    func getPet(with id: Int) {
        
        DataManager.instance.getPet(by: id) { (error, pet) in
            
            if let error = error {
                if error.DBError?.type == DatabaseErrorType.NotFound {
                    self.view?.petNotFound()
                }else{
                    self.view?.errorMessage(error.msg)
                }
            }else if let pet = pet {
                if let users = pet.sortedUsers { self.users = users }
            }
        }
    }

    
    func loadPet(with id: Int) {
        
        DataManager.instance.loadPet(id) { (error, pet) in
            
            if let error = error {
                if error.DBError?.type == DatabaseErrorType.NotFound {
                    self.view?.petNotFound()
                }else{
                    self.view?.errorMessage(error.msg)
                }
            }
        }
    }
    
    
    
    func removePetUser(with id: Int, from petId: Int) {
        DataManager.instance.removeSharedUser(by: id, from: petId) { (error) in
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.removed()
            }
        }
    }

    
    func leavePet(with id: Int) {
        
        DataManager.instance.leaveSharedPet(by: id) { (error) in
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.removed()
            }
        }
    }


    
    
    func loadPetUsers(for id: Int){
        
        DataManager.instance.loadSharedPetUsers(for: id) { (error, users) in
            if error == nil && users != nil {
                DataManager.instance.getPet(by: id) { (error, pet) in
                    if let error = error {
                        if error.DBError?.type == DatabaseErrorType.NotFound {
                            self.view?.petNotFound()
                        }else{
                            self.view?.errorMessage(error.msg)
                        }
                    }else if let pet = pet {
                        if let petUsers = pet.users {
                            self.users = petUsers
                        }
                        self.view?.loadUsers()
                    }
                }
            }else if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.errorMessage(ErrorMsg.init(title: "", msg: "Unknown Error"))
            }
        }
    }

    
}
