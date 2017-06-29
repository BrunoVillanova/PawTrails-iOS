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
}

class AddEditPetPresenter {
    
    weak private var view: AddEditPetView?
    
    var pet = Pet()
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
            
            DataManager.Instance.savePet(image: imageData, into: petId, callback: { (error) in
                
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
            
            DataManager.Instance.save(pet, callback: { (error) in
                
                self.view?.endLoadingContent()
                if let error = error {
                    self.view?.errorMessage(error.msg)
                }else{
                    self.view?.doneSuccessfully()
                }
            })
            
        }else{
            
            DataManager.Instance.register(pet, callback: { (error, pet) in
                
                if let error = error {
                    self.view?.endLoadingContent()
                    self.view?.errorMessage(error.msg)
                }else if self.imageData != nil, let pet = pet {
                    self.saveImatge(petId: pet.id)
                }else{
                    self.view?.endLoadingContent()
                    self.view?.doneSuccessfully()
                }
            })
        }
    }
}

