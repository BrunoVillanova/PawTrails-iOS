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
    
    var pets: [Pet] {
        return ownedPets + sharedPets
    }
    
    func attachView(_ view: PetsView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getPet(with id: Int) -> Pet? {
        return pets.first(where: { $0.id == id })
    }
    
    func getPets() {
        
        DataManager.Instance.getPetsSplitted { (error, owned, shared) in
            
            if let error = error {
                if error.DBError == DatabaseError.NotFound {
                    self.ownedPets.removeAll()
                    self.sharedPets.removeAll()
                    self.view?.petsNotFound()
                }else{
                    self.view?.errorMessage(error.msg)
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
    
    func loadPets() {
        
        DataManager.Instance.loadPets { (error, pets) in
            
            if let error = error {
                if error.DBError == DatabaseError.NotFound {
                    self.ownedPets.removeAll()
                    self.sharedPets.removeAll()
                    self.view?.petsNotFound()
                }else{
                    self.view?.errorMessage(error.msg)
                }
            }else {
                self.getPets()
            }
        }
    }
    
    //MARK:- Socket IO
    
    func startPetsGPSUpdates(_ callback: @escaping ((_ id: Int)->())){
        
        NotificationManager.Instance.getPetGPSUpdates({ (id, data) in
            callback(id)
        })
    }
    
    func stopPetGPSUpdates(){
        NotificationManager.Instance.removePetGPSUpdates()
    }
    
    //MARK:- Geocode
    
    func startPetsGeocodeUpdates(_ callback: @escaping ((Geocode)->())){
        NotificationManager.Instance.getPetGeoCodeUpdates { (code) in
            if let code = code { callback(code) }
        }
    }
    
    func stopPetsGeocodeUpdates(){
        NotificationManager.Instance.removePetGeoCodeUpdates()
    }
    
    //LoadPets
    
    func startPetsListUpdates(){
        NotificationManager.Instance.getPetListUpdates { (pets) in
            debugPrint("Time to update pets on list")
            if let pets = pets {
                self.ownedPets = pets.filter({ $0.isOwner })
                self.sharedPets = pets.filter({ !$0.isOwner })
                self.view?.loadPets()
            }else {
                self.view?.petsNotFound()
            }
        }
    }
    
    func stopPetListUpdates(){
        NotificationManager.Instance.removePetListUpdates()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
