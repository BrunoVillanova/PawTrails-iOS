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
    
//    var pets = [Pet]()
    var pets = ["Billy"]
    
    func attachView(_ view: PetsView){
        self.view = view
        getPets()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getPets() {
        DataManager.Instance.getPets { (error, pets) in
            DispatchQueue.main.async {
                if error != nil {
                    self.view?.errorMessage(ErrorMsg(title: "",msg: "\(String(describing: error))"))
                }else if pets != nil {
                    self.view?.loadPets()
                }
            }
        }
    }
    
}
