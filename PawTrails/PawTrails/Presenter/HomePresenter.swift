//
//  HomePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol HomeView: NSObjectProtocol, View, ConnectionView {
    func reload()
    func startTracking(_ name: String, lat:Double, long:Double)
    func updateTracking(_ name: String, lat:Double, long:Double)
    func stopTracking(_ name: String)
    func userNotSigned()
}

class HomePresenter {
    
    weak fileprivate var view: HomeView?
    private var reachability: Reachbility!

    var pets = [_pet]()
    var user:User!
    
    
    func attachView(_ view: HomeView){
        self.view = view
        self.reachability = Reachbility(view)
        self.getUser()
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
            }else if error == UserError.NotAuthenticated {
                self.view?.userNotSigned()
            }else{
                self.view?.errorMessage(ErrorMsg(title: "Unable to get user info", msg: "\(String(describing: error))"))
            }
        }
        }
    }
    
    func testPets() {
//        self.pets = [_pet]()
//        for i in 0...200 {
//            self.pets.append(_pet("pet\(i)"))
//        }
    }
    
    //Socket IO
    
    func startTracking(_ i: Int){
        
//        if !self.pets.indices.contains(i) || !DataManager.Instance.trackingIsIdle() {
//            self.view?.errorMessage(ErrorMsg(title:"Error", msg: "Tracking is not available for this pet: \(SocketIOManager.Instance.connectionStatus())"))
//        }
//        let pet = self.pets[i]
//        DataManager.Instance.startTracking(pet: pet, callback: { (lat,long) in
//            if pet.tracking {
//                DispatchQueue.main.async {
//                    self.view?.updateTracking(pet.name, lat: lat, long: long)
//                }
//            }else{
//                pet.tracking = true
//                DispatchQueue.main.async {
//                    self.view?.startTracking(pet.name, lat: lat, long: long)
//                }
//            }
//        })
    }
    
    func stopTracking(_ i: Int){
//        if !self.pets.indices.contains(i) {
//            self.view?.errorMessage(ErrorMsg(title:"Error", msg: "Couldn't find the pet"))
//        }
//        let pet = self.pets[i]
//        pet.tracking = false
//        DataManager.Instance.stopTracking(pet: pet)
//        DispatchQueue.main.async {
//            self.view?.stopTracking(pet.name)
//        }
    }
    
    func testTrackingAllPets(){
//        for i in 0...self.pets.count - 1 {
//            if self.pets[i].tracking  {
//                self.stopTracking(i)
//            }else{
//                self.startTracking(i)
//            }
//        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

