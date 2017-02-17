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
    func plotPoint(latitude:Double, longitude:Double)
}

class HomePresenter {
    
    weak fileprivate var view: HomeView?
    
    func attachView(_ view: HomeView){
        self.view = view
        SocketIOManager.Instance.startListeningUpdates()
        getPoints()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func checkSignInStatus() {
        if !AuthManager.Instance.isAuthenticated() {
            self.view?.userNotSignedIn()
        }
    }
    
    func getPoints(){
        SocketIOManager.Instance.getPoints({ (point) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.view?.plotPoint(latitude: point.latitude, longitude: point.longitude)
            })
        })
    }
}

