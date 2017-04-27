//
//  PetsPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PetsView: NSObjectProtocol, View {
    func loadPets()
    func petsNotFound()
}


class PetsPresenter {
    
    weak private var view: PetsView?
    
    var pets = [Pet]()
    
    func attachView(_ view: PetsView){
        self.view = view
        getPets()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getPets() {
        DataManager.Instance.getPets { (error, pets) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petsNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let pets = pets {
                    self.pets = pets
                    self.view?.loadPets()
                }
            }
        }
    }
    
    func loadPets() {
        DataManager.Instance.getPets { (error, pets) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petsNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let pets = pets {
                    self.pets = pets
                    self.view?.loadPets()
                }
            }
        }
    }
    
    func removePet(at index: Int) -> Bool {
        guard let petId = pets[index].id else { return false }
        if DataManager.Instance.removePet(petId) {
            pets.remove(at: index)
            return true
        }
        return false
    }
    
}
