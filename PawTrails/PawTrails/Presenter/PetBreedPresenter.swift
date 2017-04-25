//
//  PetBreedPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 19/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PetBreedsView: NSObjectProtocol, View {
    func breedsNotFound()
    func loadBreeds()
}


class PetBreedsPresenter {
    
    weak private var view: PetBreedsView?
    
    var breeds = [Breed]()
    
    func attachView(_ view: PetBreedsView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getBreeds(for type: Type) {
        
        DataManager.Instance.getBreeds(for: type, callback: { (error, breeds) in
            
            DispatchQueue.main.async {
                if error == nil, let breeds = breeds {
                    self.breeds = breeds
                    self.view?.loadBreeds()
                }else{
                    self.view?.breedsNotFound()
                }
            }
        })
        
    }
    
}
