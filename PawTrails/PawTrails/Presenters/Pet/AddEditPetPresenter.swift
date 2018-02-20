//
//  AddEditPetPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 12/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol AddEditPetView: NSObjectProtocol, View, LoadingView {
    func loadPet()
    func doneSuccessfully()
    func codeChanged()
    func petRemoved()

}

class AddEditPetPresenter {
    
    weak private var view: AddEditPetView?
    
    var pet = Pet()
    var savedPet = Pet()
    private var editMode: Bool = false
    var imageData: Data? = nil
    
    func attachView(_ view: AddEditPetView, _ pet: Pet?, _ deviceCode: String?){
        self.view = view
        
        if let pet = pet {
            self.pet = pet
            editMode = true
            view.loadPet()
        }
        self.pet.deviceCode = deviceCode
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func set(image data:Data?){
        imageData = data
    }
    
    func refresh(){
        view?.loadPet()
    }
    
    func done(){
        if editMode, imageData != nil {
            saveImatge(petId: pet.id)
        }else{
            save()
            
        }
    }
    
    private func saveImatge(petId:Int){
        
        if let imageData = imageData {
            
            DataManager.instance.savePet(image: imageData, into: petId, callback: { (error) in
                
                if let error = error {
                    self.view?.endLoadingContent()
                    self.view?.errorMessage(error.msg)
                }else{
                    self.imageData = nil
                    if self.editMode {
                        self.save()
                    }else{
                        self.view?.endLoadingContent()
                        self.view?.doneSuccessfully()
                    }
                }
            })
        }
    }
    
    private func save(){
        
        view?.beginLoadingContent()
        if editMode  {
            DataManager.instance.save(pet, callback: { (error) in
                self.view?.endLoadingContent()
                if let error = error {
                    self.view?.errorMessage(error.msg)
                }else{
                    self.view?.doneSuccessfully()
                }
            })
            
        }else{
            DataManager.instance.register(pet, callback: { (error, pet) in
                if let error = error {
                    self.view?.endLoadingContent()
                    self.view?.errorMessage(error.msg)
                }else if self.imageData != nil, let pet = pet {
                    self.savedPet = pet
                    self.view?.endLoadingContent()
                    self.view?.doneSuccessfully()
                }else{
                    
                    self.view?.endLoadingContent()
                    self.view?.doneSuccessfully()
                }
            })
        }
    }
    
    func change(_ code:String, to petId: Int){
        
        DataManager.instance.change(code, of: petId) { (error) in
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.codeChanged()
            }
        }
    }
    
    func removePet(with id: Int) {
        
        view?.beginLoadingContent()
        DataManager.instance.removePet(id) { (error) in
            self.view?.endLoadingContent()
            if (((error?.APIError) != nil)||((error?.responseError) != nil)||((error?.error) != nil)) {
                //self.view?.removed()
                debugPrint("Error removing pet : \(String(describing: error))")
            }else{
                self.view?.petRemoved()
                print("removed")
            }
        }
    }
}

