//
//  AddEditSafeZonePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 17/05/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol AddEditSafeZoneView: NSObjectProtocol, View, ConnectionView, LoadingView {
    func success()
    func missingName()
}

class AddEditSafeZonePresenter {
    
    weak fileprivate var view: AddEditSafeZoneView?
    private var reachability: Reachbility!

    func attachView(_ view: AddEditSafeZoneView){
        self.view = view
        self.reachability = Reachbility(view)
    }
    
    func deteachView() {
        self.view = nil
    }

    
    func addEditSafeZone(safezoneId: Int16, name: String?, shape: Shape, active: Bool, points: (Point,Point), into petId: Int16){
        
        if name == nil || (name != nil && name == "") {
            view?.missingName()
        }else{
            
            var data = [String:Any]()
            data["name"] = name
            data["shape"] = shape.code
            data["point1"] = points.0.toDict
            data["point2"] = points.1.toDict
            data["active"] = active
            
            if safezoneId != -1 {
                data["id"] = safezoneId
                DataManager.Instance.setSafeZone(by: data, to: petId, callback: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.view?.errorMessage(error.msg)
                        }else{
                            self.view?.success()
                        }
                    }
                })
            }else{
                data["petid"] = petId
                DataManager.Instance.addSafeZone(by: data, to: petId, callback: { (error, _) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.view?.errorMessage(error.msg)
                        }else{
                            self.view?.success()
                        }
                    }
                })
            }
        }
    }
    
    func removeSafeZone(_ id: Int16, into petId: Int16) {
        
        DataManager.Instance.removeSafeZone(by: id, to: petId) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.view?.errorMessage(error.msg)
                }else{
                    self.view?.success()
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
