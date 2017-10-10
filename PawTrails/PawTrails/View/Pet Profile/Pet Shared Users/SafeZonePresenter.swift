//
//  SafeZonePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 06/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


protocol SazeZoneView: NSObjectProtocol, View {
    func loadSafeZones()
    func load(_ pet:Pet)
    func petNotFound()


}

//
class SazeZonePresnter {
    weak private var view: SazeZoneView?
    
    var safeZones = [SafeZone]()
    func attacheView(_ view: SazeZoneView, pet: Pet?) {
        if let safezones = pet?.safezones { self.safeZones = safezones }

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
                if let safezones = pet.sortedSafeZones { self.safeZones = safezones }
                self.view?.load(pet)
            }
        }
    }
    
    
    
    func deteachView() {
        self.view = nil
    }

    
    //MARK:- Safe Zones
    
    
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
                            self.safeZones = safezones
                        }
                        DispatchQueue.main.async {
                            self.view?.loadSafeZones()

                        }
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


}


