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
        
        DataManager.Instance.getPets { (error, pets) in
        }
    }
    
    func loadPets() {
        DataManager.Instance.loadPets { (error, pets) in
            DispatchQueue.main.async {
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
    }
    
    //MARK:- Socket IO
    
    func startPetsGPSUpdates(_ callback: @escaping ((_ id: Int16, _ update: Bool)->())){
        NotificationManager.Instance.getPetGPSUpdates { (id, data) in
            if data.locationAndTime == "" {  GeocoderManager.Intance.reverse(data.point, for: id) }
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
    
    //LoadPets
    
    func startPetsListUpdates(){
        NotificationManager.Instance.getPetListUpdates { (pets) in
            debugPrint("Update PETS!!")
            DispatchQueue.main.async {
                if let pets = pets {
                    self.ownedPets = pets.filter({ $0.isOwner })
                    self.sharedPets = pets.filter({ !$0.isOwner })
                    self.view?.loadPets()
                }else {
                    self.view?.petsNotFound()
                }
            }
        }
    }
    
    func stopPetListUpdates(){
        NotificationManager.Instance.removePetListUpdates()
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
