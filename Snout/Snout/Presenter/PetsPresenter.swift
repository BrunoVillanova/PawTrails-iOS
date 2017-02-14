//
//  PetsPresenter.swift
//  Snout
//
//  Created by Marc Perello on 10/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PetsView: NSObjectProtocol, View {
    func petsNotFound()
    func reload(_ user: User, _ pets:[Pet])
}

class PetsPresenter {
    
    weak fileprivate var petsView: PetsView?
    
    func attachView(_ view: PetsView){
        self.petsView = view
    }
    
    func deteachView() {
        self.petsView = nil
    }
    
    func getPetsAndUser(){
//        APIManager.Instance.performCall(.getpets) { (error, data) in
//            //
//        }
//        let location = Location(latitude: 51.8902636,longitude: -8.4956673)
//        var pets = [Pet]()
//        for i in 1...10 {
//            let pet = try? Pet(["id": i, "name": "name\(i)"])
////            pet?.location = location
////            pet?.location?.latitude = (pet?.location?.latitude)! - Double(i)
////            pet?.location?.longitude = (pet?.location?.longitude)! + Double(i)
//            pets.append(pet!)
//        } 
//        
//        self.petsView?.loadPets(pets)
        DataManager.Instance.getUser { (error, user) in
            if error == nil && user != nil {
                DispatchQueue.main.async {
                    self.petsView?.reload(user!, [Pet]())
                }
            }
        }
    }
    
}

