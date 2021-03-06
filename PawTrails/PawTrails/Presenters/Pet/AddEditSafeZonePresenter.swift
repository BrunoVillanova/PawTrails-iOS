//
//  AddEditSafeZonePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 17/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol AddEditSafeZoneView: NSObjectProtocol, View, LoadingView {
    func success()
    func missingName()
    func petLocationFailed()
}

class AddEditSafeZonePresenter {
    
    weak fileprivate var view: AddEditSafeZoneView?
    
    func attachView(_ view: AddEditSafeZoneView, safezone: SafeZone?){
        self.view = view
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func addEditSafeZone(safezoneId: Int, name: String?, shape: Shape, active: Bool, points: (Point,Point), imageId: Int, into petId: Int){
        if name == nil || (name != nil && name == "") {
            view?.missingName()
        }else{
            let safezone = SafeZone(id: safezoneId, name: name, point1: points.0, point2: points.1, shape: shape, active: active, address: nil, preview: nil, image: Int16(imageId))
            if safezoneId != 0 {
                view?.beginLoadingContent()
                DataManager.instance.save(safezone, into: petId, callback: { (error) in
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.success()
                    }
                })
                
            }else{
                view?.beginLoadingContent()
                DataManager.instance.add(safezone, to: petId, callback: { (error, _) in
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.success()
                    }
                })
            }
        }
    }
    
    func removeSafeZone(_ id: Int, into petId: Int) {
        view?.beginLoadingContent()
        DataManager.instance.removeSafeZone(by: id, to: petId) { (error) in
             self.view?.endLoadingContent()
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.success()
            }
        }
    }
    
    //MARK:- Socket IO
    
    @objc private func petLocationFailed(){
        DispatchQueue.main.async {
            self.view?.petLocationFailed()
        }
    }
}
