//
//  SelectPetView.swift
//  PawTrails
//
//  Created by Marc Perello on 15/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol SelectPetView: NSObjectProtocol, View {
}


class SelectedPetView {
    weak private var view: SelectPetView?
    
    var trips = [Trip]()
    
    var tripList = [TripList]()
    
    func attatchView(_ view: SelectPetView) {
        self.view = view

    }
    
    
    
    func deteachView() {
        self.view = nil
    }
   
    
    
    func getTripList(with status: [Int]) {
        
    APIRepository.instance.getTripList(status) { (error, trips) in
        if let error = error {
            self.tripList.removeAll()
            self.view?.errorMessage(ErrorMsg(title: "", msg: error.localizedDescription))
        } else if let trips = trips {
            self.tripList = trips
        }
    }
}
    
    
    func startTrip(with ids: [Int]) {
        APIRepository.instance.startTrips(ids) { (error, trips) in
            if let error = error {
                self.trips.removeAll()
                self.view?.errorMessage(ErrorMsg(title: "", msg: error.localizedDescription))
            } else if let trips = trips {
                
                print(trips)
                self.trips = trips
            }
        }
    }
    
    
    
    
    
}




