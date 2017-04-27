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
    private var firstBreed: Breed?
    private var secondBreed: Breed?
    private var editMode: Bool = false
    
    func attachView(_ view: AddEditPetView, _ pet: Pet?){
        self.view = view
        if let pet = pet {
            data = pet.toDict
            firstBreed = pet.firstBreed
            secondBreed = pet.secondBreed
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
    
    func getBreeds() -> [Breed]? {
        if firstBreed == nil && secondBreed == nil { return nil }
        var breeds = [Breed]()
        if let firstBreed = firstBreed { breeds.append(firstBreed) }
        if let secondBreed = secondBreed { breeds.append(secondBreed) }
        return breeds
    }
    
    func getBreedsText() -> String? {
        
        if let breeds = getBreeds() {
            return (breeds.map { $0.name } as! [String]).joined(separator: " - ")
        }
        return nil
    }
    
    func getBirthday() -> Date? {
        return data["birthday"] as? Date
    }
    
    func getWeight() -> Weight? {
        return data["weight"] as? Weight
    }
    
    func getNeutred() -> Bool? {
        return data["neutred"] as? Bool
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

    func set(first: Breed?) {
        firstBreed = first
    }
    
    func set(second: Breed?) {
        secondBreed = second
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
    
    func set(neutred:Bool?){
        data["neutred"] = neutred
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
        
        if let firstBreed = firstBreed { data["breed"] = firstBreed.id }
        if let secondBreed = secondBreed { data["breed1"] = secondBreed.id }
        
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

