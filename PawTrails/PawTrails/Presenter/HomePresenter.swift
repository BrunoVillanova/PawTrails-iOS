//
//  HomePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol HomeView: NSObjectProtocol, View {
    func loadPets()
    func reload()
    func noPetsFound()
    func userNotSigned()
}

class HomePresenter {
    
    weak fileprivate var view: HomeView?
    

    var pets = [Pet]()
    var safeZones = [SafeZone]()
    var user:User!
    
    
    func attachView(_ view: HomeView){
        self.view = view
        
    }
    
    func deteachView() {
        self.view = nil
    }
    
    
    
    func getUser(){
        
        DataManager.Instance.getUser { (error, user) in
            DispatchQueue.main.async {
                
                if error == nil && user != nil {
                    self.user = user
                    self.view?.reload()
                }else if error?.APIError?.errorCode == ErrorCode.Unauthorized {
                    self.view?.userNotSigned()
                }else if let error = error {
                    self.view?.errorMessage(error.msg)
                }
            }
        }
    }
    
    func getPets(){
        DispatchQueue.global(qos: .background).async {
            DataManager.Instance.getPets { (error, pets) in
                
                DispatchQueue.main.async {
                    
                    if error == nil, let pets = pets {
                        self.pets = pets
                        self.view?.loadPets()
                        
                    }else if let error = error {
                        if error.DBError == DatabaseError.NotFound {
                            self.view?.noPetsFound()
                        }else{
                            self.view?.errorMessage(error.msg)
                        }
                    }
                }
            }
        }
    }
    
    //LoadPets
    
    func startPetsListUpdates(){
        NotificationManager.Instance.getPetListUpdates { (pets) in
            debugPrint("Time to update pets on Map")
            DispatchQueue.main.async {
                if let pets = pets {
                    self.pets = pets
                    self.view?.loadPets()
                }else {
                    self.view?.noPetsFound()
                }
            }
        }
    }
    
    func stopPetListUpdates(){
        NotificationManager.Instance.removePetListUpdates()
    }
    
    //Socket IO
    
    func startPetsGPSUpdates(_ callback: @escaping ((_ id: MKLocationId, _ point: Point)->())){
        
        NotificationManager.Instance.getPetGPSUpdates({ (id, data) in
            callback(MKLocationId(id: id, type: .pet), data.point)
        })
    }
    
    func stopPetGPSUpdates(){
        NotificationManager.Instance.removePetGPSUpdates()
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

