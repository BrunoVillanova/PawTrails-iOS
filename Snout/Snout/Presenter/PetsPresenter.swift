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

        DataManager.Instance.getUser { (error, user) in
            if error == nil && user != nil {
                DispatchQueue.main.async {
                    self.petsView?.reload(user!, [Pet]())
                }
            }
        }
    }
    
}

