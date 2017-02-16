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
    
    weak fileprivate var homeView: HomeView?
    
    func attachView(_ view: HomeView){
        self.homeView = view
        SocketIOManager.Instance.startListeningUpdates()
        getPoints()
    }
    
    func deteachView() {
        self.homeView = nil
    }
    
    func checkSignInStatus() {
        if !AuthManager.Instance.isAuthenticated() {
            self.homeView?.userNotSignedIn()
        }
    }
    
    func getPoints(){
        SocketIOManager.Instance.getPoints({ (point) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.homeView?.plotPoint(latitude: point.latitude, longitude: point.longitude)
            })
        })
    }
}

