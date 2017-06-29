//
//  PetUserPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 03/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PetUserView: NSObjectProtocol, View, LoadingView {
    func removed()
}

class PetUserPresenter {
    
    weak private var view: PetUserView?
    
    func attachView(_ view: PetUserView){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func removePet(with id: Int) {
        
        view?.beginLoadingContent()
        DataManager.Instance.removePet(id) { (error) in
            self.view?.endLoadingContent()
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.removed()
            }
        }
    }
    
    func leavePet(with id: Int) {
        
        view?.beginLoadingContent()
        DataManager.Instance.leaveSharedPet(by: id) { (error) in
            self.view?.endLoadingContent()
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.removed()
            }
        }
    }
    
    func removePetUser(with id: Int, from petId: Int) {
        view?.beginLoadingContent()
        DataManager.Instance.removeSharedUser(by: id, from: petId) { (error) in
            self.view?.endLoadingContent()
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.removed()
            }
        }
    }
    
}
