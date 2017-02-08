//
//  HomePresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol HomeView: NSObjectProtocol, View {
    func userNotSignedIn()
}

class HomePresenter {
    
    weak fileprivate var homeView: HomeView?
    
    func attachView(_ view: HomeView){
        self.homeView = view
    }
    
    func deteachView() {
        self.homeView = nil
    }
    
    func checkSignInStatus() {
//        if !AuthManager.Instance.isSignedIn() {
//            self.homeView?.userNotSignedIn()
//        }
    }
    
    func signOut(){
        AuthManager.Instance.signOut { (error) in
            if error != nil {
                self.homeView?.errorMessage(error!)
            }else{
                self.homeView?.userNotSignedIn()
            }
        }
    }
}

