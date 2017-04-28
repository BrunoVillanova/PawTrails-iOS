//
//  PetPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 28/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PetView: NSObjectProtocol, View {
    func load(_ pet:Pet)
    func petNotFound()
}


class PetPresenter {
    
    weak private var view: PetView?
    
    func attachView(_ view: PetView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    
    func getPet(with id: String) {
        
        DataManager.Instance.getPet(id) { (error, pet) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let pet = pet {
                    self.view?.load(pet)
                }
            }
        }
    }
    
    func loadPet(with id: String) {
        
        DataManager.Instance.loadPet(id) { (error, pet) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let pet = pet {
                    self.view?.load(pet)
                }
            }
        }
    }
}
