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
        
        DataManager.instance.getPetsSplitted { (error, owned, shared) in
            
            if let error = error {
                if error.DBError?.type == DatabaseErrorType.NotFound {
                    self.ownedPets.removeAll()
                    self.sharedPets.removeAll()
                    self.view?.petsNotFound()
                }else{
                    self.view?.errorMessage(error.msg)
                }
            }else if let owned = owned, let shared = shared {
                self.ownedPets = owned.sorted(by: { (p1, p2) -> Bool in
                    return p1.id < p2.id
                })
                self.sharedPets = shared.sorted(by: { (p1, p2) -> Bool in
                    return p1.id < p2.id
                })
                self.view?.loadPets()
            }else{
                self.ownedPets.removeAll()
                self.sharedPets.removeAll()
            }
            
        }
    }
    
    func loadPets() {
        
        DataManager.instance.loadPets { (error, pets) in
            
            if let error = error {
                if error.DBError?.type == DatabaseErrorType.NotFound {
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
        
        NotificationManager.instance.getPetGPSUpdates({ (id, data) in
            callback(id)
        })
    }
    
    func stopPetGPSUpdates(){
        NotificationManager.instance.removePetGPSUpdates()
    }
    
    //MARK:- Geocode
    
    func startPetsGeocodeUpdates(_ callback: @escaping ((Geocode)->())){
        NotificationManager.instance.getPetGeoCodeUpdates { (code) in
            callback(code)
        }
    }
    
    func stopPetsGeocodeUpdates(){
        NotificationManager.instance.removePetGeoCodeUpdates()
    }
    
    //LoadPets
    
    func startPetsListUpdates(){
        NotificationManager.instance.getPetListUpdates { (pets) in
            Reporter.debugPrint(file: "#file", function: "#function", "Time to update pets on list")
            self.ownedPets = pets.filter({ $0.isOwner })
            self.sharedPets = pets.filter({ !$0.isOwner })
            self.view?.loadPets()
        }
    }
    
    func stopPetListUpdates(){
        NotificationManager.instance.removePetListUpdates()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
