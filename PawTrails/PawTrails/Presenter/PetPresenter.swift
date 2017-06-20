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
        
        
        if let users = pet?.sharedUsers { self.users = users }
        if let safezones = pet?.sortedSafeZones {
            self.safezones = safezones
        }
    }
    
    func deteachView() {
        self.view = nil
    }
    
    
    
    
    //MARK:- Pet
    
    func getPet(with id: Int16) {
        
        DataManager.Instance.getPet(id) { (error, pet) in
            DispatchQueue.main.async {
                if let error = error {
                    if error.DBError == DatabaseError.NotFound {
                        self.view?.petNotFound()
                    }else{
                        self.view?.errorMessage(error.msg)
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
        
        DispatchQueue.global(qos: .background).async {
            DataManager.Instance.loadPet(id) { (error, pet) in
                DispatchQueue.main.async {
                    if let error = error {
                        if error.DBError == DatabaseError.NotFound {
                            self.view?.petNotFound()
                        }else{
                            self.view?.errorMessage(error.msg)
                        }
                    }else if let pet = pet {
                        self.view?.load(pet)
                    }
                }
            }
            
        }
    }
    
    func removePet(with id: Int16) {
        
        DispatchQueue.global(qos: .background).async {
            DataManager.Instance.removePet(id) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.petRemoved()
                    }
                }
            }
            
        }
    }
    
    //MARK:- Users
    
    func leavePet(with id: Int16) {
        
        DispatchQueue.global(qos: .background).async {
            DataManager.Instance.leaveSharedPet(by: id) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.petRemoved()
                    }
                }
                
            }
        }
    }
    
    func loadPetUsers(for id: Int16){
        
        DispatchQueue.global(qos: .background).async {
            DataManager.Instance.loadSharedPetUsers(for: id) { (error, users) in
                if error == nil && users != nil {
                    DataManager.Instance.getPet(id) { (error, pet) in
                        DispatchQueue.main.async {
                            if let error = error {
                                if error.DBError == DatabaseError.NotFound {
                                    self.view?.petNotFound()
                                }else{
                                    self.view?.errorMessage(error.msg)
                                }
                            }else if let pet = pet {
                                if let petUsers = pet.sharedUsers {
                                    self.users = petUsers
                                }
                                self.view?.loadUsers()
                            }
                        }
                    }
                }else if let error = error {
                    DispatchQueue.main.async {
                        self.view?.errorMessage(error.msg)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.view?.errorMessage(DataManagerError.init(DBError: DatabaseError.NotFound).msg)
                    }
                }
                
            }
        }
    }
    
    //MARK:- Safe Zones
    
    func loadSafeZones(for id: Int16){
        
        DispatchQueue.global(qos: .background).async {
            DataManager.Instance.loadSafeZones(of: id) { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view?.errorMessage(error.msg)
                    }
                }else {
                    DataManager.Instance.getPet(id) { (error, pet) in
                        DispatchQueue.main.async {
                            if let error = error {
                                if error.DBError == DatabaseError.NotFound {
                                    self.view?.petNotFound()
                                }else{
                                    self.view?.errorMessage(error.msg)
                                }
                            }else if let pet = pet {
                                if let safezones = pet.sortedSafeZones {
                                    self.safezones = safezones
                                }
                                self.view?.loadSafeZones()
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func set(safezone: SafeZone, imageData:Data){
        DataManager.Instance.setSafeZone(safezone, imageData: imageData)
    }
    
    func set(safezone: SafeZone, address:String){
        DataManager.Instance.setSafeZone(safezone, address: address)
    }
    
    func set(safezoneId: Int16, address:String){
        
        if let safezone = safezones.first(where: { $0.id == safezoneId }) {
            DataManager.Instance.setSafeZone(safezone, address: address)
        }else{
            debugPrint("AHHHHHHHHH", safezoneId, address)
        }
    }
    
    func setSafeZoneStatus(id: Int16, petId: Int16, status: Bool, callback: @escaping (Bool)->() ){
        
        DispatchQueue.global(qos: .background).async {
            DataManager.Instance.setSafeZoneStatus(enabled: status, for: id, into: petId) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                        callback(false)
                    }else{
                        self.loadSafeZones(for: petId)
                        callback(true)
                    }
                }
                
            }
        }
    }
    
    //MARK:- Socket IO
    
    func startPetsGPSUpdates(for id: Int16, _ callback: @escaping ((GPSData)->())){
        DispatchQueue.global(qos: .background).async {
            NotificationManager.Instance.getPetGPSUpdates { (id, data) in
                if id == id {
                    DispatchQueue.main.async {
                        callback(data)
                    }
                    GeocoderManager.Intance.reverse(type: .pet, with: data.point, for: id)
                }
            }
        }
    }
    
    func stopPetGPSUpdates(){
        DispatchQueue.global(qos: .background).async {
            NotificationManager.Instance.removePetGPSUpdates()
        }
    }
    
    //MARK:- Geocode
    
    func startPetsGeocodeUpdates(for id: Int16, _ callback: @escaping ((GeocodeType, String)->())){
        DispatchQueue.global(qos: .background).async {
            NotificationManager.Instance.getPetGeoCodeUpdates { (code) in
                
                if let code = code {
                    
                    if (code.type == .pet && code.id == id) || code.type == .safezone {
                        if code.type == .safezone, let name = code.placemark?.name {
                            self.set(safezoneId: code.id, address: name)
                        }
                        if let name = code.name {
                            DispatchQueue.main.async {
                                callback(code.type, name)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func stopPetsGeocodeUpdates(){
        DispatchQueue.global(qos: .background).async {
            NotificationManager.Instance.removePetGeoCodeUpdates()
        }
    }
}
