//
//  AddEditPetPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 12/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

struct _petUser {
    var name: String?
    var surname: String?
    var isOwner: Bool?
    var imageData: Data?
}

protocol AddEditPetView: NSObjectProtocol, View, LoadingView {
    func loadPet()
    func doneSuccessfully()
}


class AddEditPetPresenter {
    
    weak private var view: AddEditPetView?
    
    private var data = [String:Any]()
    private var editMode: Bool = false
    
    func attachView(_ view: AddEditPetView, _ pet: Pet?){
        self.view = view
        if let pet = pet {
            data = pet.toDict
            editMode = true
            view.loadPet()
        }
    }
    
    func deteachView() {
        self.view = nil
    }
    
    
    //MARK:- Getters
    
    
    
    func getImageData() -> Data? {
        return data["image"] as? Data
    }
    
    func getName() -> String? {
        return data["name"] as? String
    }
    
    func getType() -> String? {
        return data["type"] as? String
    }
    
    func getGender() -> Gender? {
        return Gender.build(code: data["gender"] as? String)
    }
    
    func getBreeds() -> [String]? {
        return (data["breed"] as? String)?.components(separatedBy: " - ")
    }
    
    func getBreedsText() -> String? {
        return data["breed"] as? String
    }
    
    func getBirthday() -> Date? {
        return data["birthday"] as? Date
    }
    
    func getWeight() -> Weight? {
        return data["weight"] as? Weight
    }
    
    //MARK:- Setters
    
    func set(deviceCode: String?) {
        data["deviceCode"] = deviceCode
    }
    
    func set(name: String?) {
        data["name"] = name
    }
    
    func set(type: String?) {
        data["type"] = type
    }
    
    func set(gender:Gender?){
        data["gender"] = gender?.code
    }

    func set(breeds: [String]?) {
        data["breed"] = breeds?.joined(separator: " - ")
    }
    
    func set(birthday:Date?){
        data["birthday"] = birthday
    }
    
    func set(weight:Weight?){
        data["weight"] = weight
    }
    
    func set(imageData:Data?){
        data["image"] = imageData
    }
    
    func refresh(){
        view?.loadPet()
    }
    
    func done(){
        view?.beginLoadingContent()
        
        if editMode {
            savePet()
        }else{

            data["id"] = data["deviceCode"]

            DataManager.Instance.getUser(callback: { (error, user) in
                
                if error == nil, let user = user {
                    
                    var ownerData = [String:Any]()
                    ownerData["id"] = user.id
                    ownerData["name"] = user.name
                    ownerData["surname"] = user.surname
                    ownerData["email"] = user.email
                    ownerData["imageURL"] = user.imageURL
                    ownerData["image"] = user.image

                    self.data["owner"] = ownerData
                    self.savePet()
                }
            })
        }
    }
    
    private func savePet(){
        DataManager.Instance.setPet(data, callback: { (error) in
            DispatchQueue.main.async {
                self.view?.endLoadingContent()
                if let error = error {
                    self.view?.errorMessage(ErrorMsg(title: "Error", msg: "\(error)"))
                }else{
                    self.view?.doneSuccessfully()
                }
            }
        })
    }
}

