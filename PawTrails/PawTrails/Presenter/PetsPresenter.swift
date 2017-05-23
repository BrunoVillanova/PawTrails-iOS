//
//  PetsPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PetsView: NSObjectProtocol, View {
    func loadSharedPets()
    func loadOwnedPets()
    func petsNotFound()
}


class PetsPresenter {
    
    weak private var view: PetsView?
    
    var ownedPets = [Pet]()
    var sharedPets = [Pet]()
    
    func attachView(_ view: PetsView){
        self.view = view
        getPets()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getPet(with id: Int) -> Pet? {
        let id = Int16(id)
        var pets = ownedPets
        pets.append(contentsOf: sharedPets)
        return pets.first(where: { $0.id == id })
    }
    
    func getPets() {
        getOwnedPets()
        getSharedPets()
    }
    
    private func getOwnedPets(){
        DataManager.Instance.getPets { (error, pets) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petsNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let pets = pets {
                    self.ownedPets = pets
                    self.view?.loadOwnedPets()
                }
            }
        }
    }
    
    private func getSharedPets(){
        DataManager.Instance.getPets(owned: false) { (error, pets) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petsNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let pets = pets {
                    self.sharedPets = pets
                    self.view?.loadSharedPets()
                }
            }
        }
    }
    
    func loadPets() {
        DataManager.Instance.loadPets { (error, pets) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.ownedPets.removeAll()
                        self.sharedPets.removeAll()
                        self.view?.petsNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else {
                    self.getPets()
                }
            }
        }
    }
}
