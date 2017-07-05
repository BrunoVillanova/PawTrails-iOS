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
    func loadUsers()
    func loadSafeZones()
    func petNotFound()
    func petRemoved()
}

class PetPresenter {
    
    weak private var view: PetView?
    
    var users = [PetUser]()
    var safezones = [SafeZone]()
    
    func attachView(_ view: PetView, pet:Pet?){
        self.view = view
        
        if let users = pet?.users { self.users = users }
        if let safezones = pet?.safezones { self.safezones = safezones }
    }
    
    func deteachView() {
        self.view = nil
    }
    
    //MARK:- Pet
    
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
                if let safezones = pet.sortedSafeZones { self.safezones = safezones }
                self.view?.load(pet)
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
    
    //MARK:- Users
    
    func leavePet(with id: Int) {
        
        DataManager.instance.leaveSharedPet(by: id) { (error) in
            
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.petRemoved()
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
    
    //MARK:- Safe Zones
    
    func loadSafeZones(for id: Int){
        
        DataManager.instance.loadSafeZones(of: id) { (error) in
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else {
                DataManager.instance.getPet(by: id) { (error, pet) in
                    if let error = error {
                        if error.DBError?.type == DatabaseErrorType.NotFound {
                            self.view?.petNotFound()
                        }else{
                            self.view?.errorMessage(error.msg)
                        }
                    }else if let pet = pet {
                        if let safezones = pet.safezones {
                            self.safezones = safezones
                        }
                        self.view?.loadSafeZones()
                    }
                }
            }
        }
    }
    
    func set(address:String, for id: Int, callback: @escaping (ErrorMsg?)->()){
        DataManager.instance.setSafeZone(address: address, for: id) { (error) in
            callback(error?.msg)
        }
    }
    
    func set(imageData:Data, for id: Int, callback: @escaping (ErrorMsg?)->()){
        DataManager.instance.setSafeZone(imageData: imageData, for: id) { (error) in
            callback(error?.msg)
        }
    }
    
    func setSafeZoneStatus(id: Int, petId: Int, status: Bool, callback: @escaping (Bool)->() ){
        
        DataManager.instance.setSafeZoneStatus(status: status, for: id, into: petId) { (error) in
            if let error = error {
                self.view?.errorMessage(error.msg)
                callback(false)
            }else{
                self.loadSafeZones(for: petId)
                callback(true)
            }
        }
    }
    
    //MARK:- Socket IO
    
    func startPetsGPSUpdates(for id: Int, _ callback: @escaping ((GPSData)->())){
        
        NotificationManager.instance.getPetGPSUpdates(for: id, { (id, data) in
            callback(data)
        })
    }
    
    func stopPetGPSUpdates(of id: Int){
        NotificationManager.instance.removePetGPSUpdates(of: id)
    }
    
    //MARK:- Geocode
    
    func startPetsGeocodeUpdates(for id: Int, _ callback: @escaping ((GeocodeType, String)->())){
        NotificationManager.instance.getPetGeoCodeUpdates { (code) in
            
            if (code.type == .pet && code.id == id) || code.type == .safezone {
                if code.type == .safezone, let name = code.placemark?.name {
                    self.set(address: name, for: code.id) { (msg) in
                        if let msg = msg {
                            self.view?.errorMessage(msg)
                        }else{
                            callback(code.type, code.name)
                        }
                    }
                    
                }else{
                    callback(code.type, code.name)
                }
            }
            
        }
    }
    
    func stopPetsGeocodeUpdates(){
        NotificationManager.instance.removePetGeoCodeUpdates()
    }
}
