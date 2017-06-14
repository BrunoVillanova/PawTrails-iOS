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
    
    func attachView(_ view: PetView, pet:Pet?){
        self.view = view
        if let users = pet?.sharedUsers { self.users = users }
        if let safezones = pet?.sortedSafeZones { self.safezones = safezones }
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
    
    func removePet(with id: Int16) {
        
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
    
    //MARK:- Users
    
    func leavePet(with id: Int16) {
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

    func loadPetUsers(for id: Int16){
        DataManager.Instance.loadSharedPetUsers(for: id) { (error, users) in
            if error == nil && users != nil {
                self.getPet(with: id)
            }
        }
    }
    
    //MARK:- Safe Zones
    
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
    
    func set(safezone: SafeZone, address:String){
        DataManager.Instance.setSafeZone(safezone, address: address)
    }
    
    func setSafeZoneStatus(id: Int16, petId: Int16, status: Bool, callback: @escaping (Bool)->() ){
        
        DataManager.Instance.setSafeZoneStatus(enabled: status, for: id, into: petId) { (error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.view?.errorMessage(error.msg)
                }
                callback(false)
            }else{
                self.loadSafeZone(for: petId)
                callback(true)
            }
        }
        
    }
    
    //MARK:- Socket IO
    
    func startPetsGPSUpdates(_ callback: @escaping ((_ id: Int16)->())){
        NotificationManager.Instance.getPetGPSUpdates { (id, data) in
            GeocoderManager.Intance.reverse(data.point, for: id)
        }
    }
    
    func stopPetGPSUpdates(){
        NotificationManager.Instance.removePetGPSUpdates()
    }

    //MARK:- Geocode
    
    func startPetsGeocodeUpdates(_ callback: @escaping ((Geocode?)->())){
        NotificationManager.Instance.getPetGeoCodeUpdates(callback)
    }
    
    func stopPetsGeocodeUpdates(){
        NotificationManager.Instance.removePetGeoCodeUpdates()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
