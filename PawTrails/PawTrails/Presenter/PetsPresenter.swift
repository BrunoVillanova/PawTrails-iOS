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
        
        DataManager.Instance.getPetsSplitted { (error, owned, shared) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petsNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let owned = owned, let shared = shared {
                    self.ownedPets = owned
                    self.sharedPets = shared
                    self.view?.loadPets()
                }else{
                    self.ownedPets.removeAll()
                    self.sharedPets.removeAll()
                }
            }
        }
        
        DataManager.Instance.getPets { (error, pets) in
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
