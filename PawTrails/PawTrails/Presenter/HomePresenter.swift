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
    var tripList = [Trip]()

    func attachView(_ view: HomeView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getUser(){
        
        DataManager.instance.getUser { (error, user) in
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
    
    func getPets(){
        
        DataManager.instance.getPets { (error, pets) in
            
            if error == nil, let pets = pets {
                self.pets = pets
                self.view?.loadPets()
                
            }else if let error = error {
                if error.DBError?.type == DatabaseErrorType.NotFound {
                    self.view?.noPetsFound()
                }else{
                    self.view?.errorMessage(error.msg)
                }
            }
        }
    }
    
    //LoadPets
    
    func startPetsListUpdates(){
        NotificationManager.instance.getPetListUpdates { (pets) in
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Time to update pets on Map")
            self.pets = pets
            self.view?.loadPets()

        }
    }
    
    func stopPetListUpdates(){
        NotificationManager.instance.removePetListUpdates()
    }
    
    //Socket IO
    
    func startPetsGPSUpdates(_ callback: @escaping ((_ id: MKLocationId, _ point: Point)->())){
        
        NotificationManager.instance.getPetGPSUpdates({ (id, data) in
            if data.status == .idle { callback(MKLocationId(id: id, type: .pet), data.point) }            
        })
    }
    
    func stopPetGPSUpdates(){
        NotificationManager.instance.removePetGPSUpdates()
    }

    

    
}

