//
//  AddPetUserPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 26/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol AddPetUserView: NSObjectProtocol, View, LoadingView {
    func loadFriends()
    func successfullyAdded()
    func emailFormat()
}

class AddPetUserPresenter {
    
    weak fileprivate var view: AddPetUserView?
    
    var friends = [PetUser]()
    
    func attachView(_ view: AddPetUserView, pet: Pet){
        self.view = view
        
        getFriends(for: pet)
        loadFriends()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getFriends(for pet:Pet){
        DataManager.Instance.getPetFriends(for: pet) { (error, friends) in
            DispatchQueue.main.async {
                if error == nil, let friends = friends {
                    self.friends = friends
                    self.view?.loadFriends()
                }else if let error = error {
                    self.view?.errorMessage(error.msg)
                }
            }
        }
    }
    
    func loadFriends(){
        
        DataManager.Instance.loadPetFriends { (error, friends) in
            DispatchQueue.main.async {
                if error == nil, let friends = friends {
                    self.friends = friends
                    self.view?.loadFriends()
                }else if let error = error {
                    self.view?.errorMessage(error.msg)
                }
            }
        }
    }
    
    func addPetUser(by email: String?, to petId: Int16?) {
        
        if email == nil || (email != nil && !email!.isValidEmail) {
            view?.emailFormat()
        }else if let petId = petId {
            view?.beginLoadingContent()
            var data = [String:Any]()
            data["email"] = email
            DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error, users) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.successfullyAdded()
                    }
                }
            })
        }
        
    }
}
