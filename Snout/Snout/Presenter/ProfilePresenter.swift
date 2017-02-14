//
//  ProfilePresenter.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol ProfileView: NSObjectProtocol, View {
    func changeToEdit()
    func changeToView()
}

class ProfilePresenter {
    
    weak fileprivate var profileView: ProfileView?
    
    func attachView(_ view: ProfileView){
        self.profileView = view
    }
    
    func deteachView() {
        self.profileView = nil
    }
    
}

