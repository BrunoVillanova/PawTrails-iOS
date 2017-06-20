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
    
    
    
    func removePet(with id: Int16) {
            view?.beginLoadingContent()
            DataManager.Instance.removePet(id) { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.removed()
                    }
                }
            }
    }
    
    func leavePet(with id: Int16) {
            view?.beginLoadingContent()
            DataManager.Instance.leaveSharedPet(by: id) { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.removed()
                    }
                }
            }
    }
    
    
    func removePetUser(with id: Int16, from petId: Int16) {
            view?.beginLoadingContent()
            var data = [String:Any]()
            data["user_id"] = id
            DataManager.Instance.removeSharedUser(by: data, to: petId) { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.removed()
                    }
                }
            }
    }
    
    
    
}
