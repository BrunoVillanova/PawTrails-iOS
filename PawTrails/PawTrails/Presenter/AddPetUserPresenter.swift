//
//  AddPetUserPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 26/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol AddPetUserView: NSObjectProtocol, View, ConnectionView {
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
                }else{
                    self.view?.errorMessage(ErrorMsg(title: "", msg: "\(error.debugDescription)"))
                }
            }
        }
    }
    
    func addPetUser(by email: String?) {
        
        if email == nil || (email != nil && !email!.isValidEmail) {
            view?.emailFormat()
        }else{
            //rq
        }
        
    }
}
