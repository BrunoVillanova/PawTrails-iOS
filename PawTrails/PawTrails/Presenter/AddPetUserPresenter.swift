//
//  AddPetUserPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 26/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol AddPetUserView: NSObjectProtocol, View, ConnectionView, LoadingView {
    func loadFriends()
    func successfullyAdded()
    func emailFormat()
}

class AddPetUserPresenter {
    
    weak fileprivate var view: AddPetUserView?
    private var reachability: Reachbility!
    
    var friends = [PetUser]()
    
    func attachView(_ view: AddPetUserView){
        self.view = view
        self.reachability = Reachbility(view)
        getFriends()
        loadFriends()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getFriends(){
        DataManager.Instance.getPetFriends { (error, friends) in
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
            DataManager.Instance.addSharedUser(by: data, to: petId, callback: { (error) in
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
