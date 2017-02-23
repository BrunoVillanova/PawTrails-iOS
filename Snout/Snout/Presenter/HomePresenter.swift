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
    func checkLocationAuthorization()
    func plotPoint(latitude:Double, longitude:Double)
    func reload(_ user: User, _ pets: [Pet])
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
        }else{
            getUser()
            self.view?.checkLocationAuthorization()
        }
    }
    
    func getPoints(){
        SocketIOManager.Instance.getPoints({ (point) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.view?.plotPoint(latitude: point.latitude, longitude: point.longitude)
            })
        })
    }
    
    func getUser(){
        
        DataManager.Instance.getUser { (error, user) in
            if error == nil && user != nil {
                DispatchQueue.main.async {
                    self.view?.reload(user!, [Pet]())
                }
            }
        }
    }

}

