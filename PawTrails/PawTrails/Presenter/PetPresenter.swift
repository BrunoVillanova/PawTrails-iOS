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
    func petRemoved()
}


class PetPresenter {
    
    weak private var view: PetView?
    
    var users = [PetUser]()
    var safezones = [SafeZone]()
    
    func attachView(_ view: PetView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getPet(with id: Int16) {

        DataManager.Instance.getPet(id) { (error, pet) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == PetError.PetNotFoundInDataBase {
                        self.view?.petNotFound()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "",msg: "\(error)"))
                    }
                }else if let pet = pet {
                    if let petUsers = pet.sharedUsers {
                        self.users = petUsers
                    }
                    if let safezones = pet.sortedSafeZones {
                        self.safezones = safezones
                    }
                    self.view?.load(pet)
                }
            }
        }
    }
    
    func loadPet(with id: Int16) {
        
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
    
    func removePet(with id: Int16) {
        
        DataManager.Instance.removePet(id) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    
                    self.view?.errorMessage(ErrorMsg(title: "", msg: "\(error)"))
                }else{
                    self.view?.petRemoved()
                }
            }
        }
    }
    
    func leavePet(with id: Int16) {
        var data = [String:Any]()
        data["user_id"] = SharedPreferences.get(.id)
        DataManager.Instance.removeSharedUser(by: data, to: id) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    
                    self.view?.errorMessage(ErrorMsg(title: "", msg: "\(error)"))
                }else{
                    self.view?.petRemoved()
                }
            }
        }
    }
    
    
    func loadPetUsers(for id: Int16){
        DataManager.Instance.loadSharedPetUsers(for: id) { (error, users) in
            if error == nil && users != nil {
                self.getPet(with: id)
            }
        }
    }
    
    func loadSafeZone(for id: Int16){
        DataManager.Instance.loadSafeZones(of: id) { (error) in
            if error == nil {
                self.getPet(with: id)
            }
        }
    }
    
    func set(safezone: SafeZone, imageData:Data){
        DataManager.Instance.setSafeZone(safezone, imageData: imageData)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
