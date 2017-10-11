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
    func loadSafeZones()
    func petRemoved()
}



class PetProfilePressenter {
    
    weak private var view: ProfilePetView?
    
//    var pet: Pet!
    
    var safezones = [SafeZone]()


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
    

    func getPet(with id: Int) {
        DataManager.instance.getPet(by: id) { (error, pet) in
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
    
    //MARK:- Socket IO
    
    func startPetsGPSUpdates(for id: Int, _ callback: @escaping ((GPSData)->())){
        
        NotificationManager.instance.getPetGPSUpdates(for: id, { (id, data) in
            callback(data)
        })
    }
    
    func stopPetGPSUpdates(of id: Int){
        NotificationManager.instance.removePetGPSUpdates(of: id)
    }
    
    
    func set(address:String, for id: Int, callback: @escaping (ErrorMsg?)->()){
        DataManager.instance.setSafeZone(address: address, for: id) { (error) in
            callback(error?.msg)
        }
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
                    
                }else if code.type == .pet, let data = SocketIOManager.instance.getGPSData(for: code.id){
                    callback(code.type, data.locationAndTime)
                }
            }
            
        }
    }
    
    func stopPetsGeocodeUpdates(){
        NotificationManager.instance.removePetGeoCodeUpdates()
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
                            self.safezones = safezones
                        }
                        self.view?.loadSafeZones()
                    }
                }
            }
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

    func set(imageData:Data, for id: Int, callback: @escaping (ErrorMsg?)->()){
        DataManager.instance.setSafeZone(imageData: imageData, for: id) { (error) in
            callback(error?.msg)
        }
    }

}
