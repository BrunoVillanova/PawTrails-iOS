//
//  HomePresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol HomeView: NSObjectProtocol, View, ConnectionView {
    func userNotSignedIn()
    func reload()
    func startTracking(_ name: String, lat:Double, long:Double)
    func updateTracking(_ name: String, lat:Double, long:Double)
    func stopTracking(_ name: String)
}

class HomePresenter {
    
    weak fileprivate var view: HomeView?
    private var reachability: Reachbility!

    var pets = [_pet]()
    var user:User!
    
    
    func attachView(_ view: HomeView){
        self.view = view
        self.reachability = Reachbility(view)
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func checkSignInStatus() {
        if !AuthManager.Instance.isAuthenticated() {
            self.view?.userNotSignedIn()
        }else{
            getUser()
        }
    }
    
    func getUser(){
        
        DataManager.Instance.getUser { (error, user) in
            if error == nil && user != nil {
                self.user = user
                DispatchQueue.main.async {
                    self.testPets()
                    self.view?.reload()
                }
            }
        }
    }
    
    func testPets() {
        self.pets = [_pet]()
        for i in 0...200 {
            self.pets.append(_pet("pet\(i)"))
        }
    }
    
    //Socket IO
    
    
    func startTracking(_ i: Int){
        if self.pets.indices.contains(i) {
            let pet = self.pets[i]
            
            if SocketIOManager.Instance.launch(name: pet.name) {

                SocketIOManager.Instance.listen(name: pet.name, { (lat, long) in
                    
                    if pet.tracking {
                        self.view?.updateTracking(pet.name, lat: lat, long: long)
                    }else{
                        pet.tracking = true
                        DispatchQueue.main.async {
                            self.view?.startTracking(pet.name, lat: lat, long: long)
                        }
                    }
                })
            }else{
                self.view?.errorMessage(errorMsg(title:"Error", msg: "Couldn't connect with the server"))
            }
        }else{
            self.view?.errorMessage(errorMsg(title:"Error", msg: "Couldn't find the pet"))
        }
    }
    
    func stopTracking(_ i: Int){
        if self.pets.indices.contains(i) {
            let pet = self.pets[i]
            pet.tracking = false
            SocketIOManager.Instance.stop(name: pet.name)
            self.view?.stopTracking(pet.name)
        }else{
            self.view?.errorMessage(errorMsg(title:"Error", msg: "Couldn't find the pet"))
        }
    }
    
    func testTrackingAllPets(){
        for i in 0...self.pets.count - 1 {
            if self.pets[i].tracking  {
                self.stopTracking(i)
            }else{
                self.startTracking(i)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

