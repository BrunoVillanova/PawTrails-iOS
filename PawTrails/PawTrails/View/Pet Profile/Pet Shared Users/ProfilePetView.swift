//
//  ProfilePetView.swift
//  PawTrails
//
//  Created by Marc Perello on 08/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//


import Foundation

protocol ProfilePetView: NSObjectProtocol, View {
    func load(_ pet:Pet)

    func petNotFound()
    func petRemoved()
}



class PetProfilePressenter {
    
    weak private var view: ProfilePetView?
    
//    var pet: Pet!

    func attachView(_ view: ProfilePetView, pet:Pet?){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
}
    
    
    func loadPet(with id: Int) {
        
        DataManager.instance.loadPet(id) { (error, pet) in
            
            if let error = error {
                if error.DBError?.type == DatabaseErrorType.NotFound {
                    self.view?.petNotFound()
                }else{
                    self.view?.errorMessage(error.msg)
                }
            }else if let pet = pet {
                self.view?.load(pet)
            }
        }
    }
    
    func removePet(with id: Int) {
        
        DataManager.instance.removePet(id) { (error) in
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.petRemoved()
            }
        }
    }


}
