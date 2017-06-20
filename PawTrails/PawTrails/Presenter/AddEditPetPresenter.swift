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
    private var otherBreed: String?
    private var editMode: Bool = false
    private var imageData: Data? = nil
    
    func attachView(_ view: AddEditPetView, _ pet: Pet?, _ deviceCode: String?){
        self.view = view
        
        if let pet = pet {
            data = pet.toDict
            set(first: pet.firstBreed)
            set(second: pet.secondBreed)
            editMode = true
            view.loadPet()
        }
        if let deviceCode = deviceCode {
            set(deviceCode: deviceCode)
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
    
    func getType() -> Type? {
        if let code = data["type"] as? Int16 {
            return Type(rawValue: code)
        }
        return nil
    }
    
    func getTypeDescription() -> String? {
        return data["type_descr"] as? String
    }
    
    func getTypeText() -> String? {
        if let type = getType() {
            if let description = getTypeDescription(), description != "" { return type.name + " - " + description }
            return type.name
        }
        return nil
    }
    
    func getGender() -> Gender? {
        if let code = data["gender"] as? Int16 {
            return Gender(rawValue: code)
        }
        return nil
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
        return data["breed_descr"] as? String
    }
    
    func getOtherBreed() -> String? {
        return data["breed_descr"] as? String
    }
    
    func getBirthday() -> Date? {
        return data["birthday"] as? Date
    }
    
    func getWeight() -> Double? {
        return data["weight"] as? Double
    }
    
    func getNeutered() -> Bool? {
        return data["neutered"] as? Bool
    }
    
    //MARK:- Setters
    
    func set(deviceCode: String?) {
        data["device_code"] = deviceCode ?? ""
    }
    
    func set(name: String?) {
        data["name"] = name ?? ""
    }
    
    func set(type: Type?) {
        data["type"] = type?.rawValue ?? ""
    }
    
    func set(typeDescription: String?) {
        data["type_descr"] = typeDescription ?? ""
    }
    
    func set(gender:Gender?){
        data["gender"] = gender?.rawValue ?? ""
    }
    
    func set(first: Breed?) {
        firstBreed = first
        data["breed"] = first?.id
    }
    
    func set(second: Breed?) {
        secondBreed = second
        data["breed1"] = second?.id
    }
    
    func set(otherBreed: String?) {
        data["breed_descr"] = otherBreed ?? ""
    }
    
    func set(birthday:Date?){
        data["birthday"] = birthday ?? ""
    }
    
    func set(weight:Double?){
        data["weight"] = weight ?? ""
    }
    
    func set(image data:Data?){
        imageData = data
    }
    
    func set(neutered:Bool?){
        data["neutered"] = neutered ?? ""
    }
    
    func refresh(){
        view?.loadPet()
    }
    
    func done(){
        
        if editMode, let id = data["id"] as? Int16, imageData != nil {
            saveImatge(petId: id)
        }else{
            save()
        }
    }
    
    private func saveImatge(petId:Int16){
        
        if let imageData = imageData {
            var data = [String:Any]()
            data["path"] = "pet"
            data["petid"] = petId
            data["picture"] = imageData
            print(imageData.count/1024)
            
            DataManager.Instance.set(image: data, callback: { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view?.endLoadingContent()
                        self.view?.errorMessage(error.msg)
                    }
                }else{
                    self.imageData = nil
                    if self.editMode {
                        self.save()
                    }else{
                        DispatchQueue.main.async {
                            self.view?.endLoadingContent()
                            self.view?.doneSuccessfully()
                        }
                    }
                }
            })
        }
    }
    
    private func save(){
        
        view?.beginLoadingContent()
        if let birthdate = data["birthday"] as? Date? {
            data["date_of_birth"] = birthdate?.toStringServer ?? ""
        }
        
        data["type"] = getType()?.code ?? ""
        data["gender"] = getGender()?.code ?? ""
        
        data.filter(by: ["image", "imageURL", "birthday"])
        
        if editMode, let id = data["id"] as? Int16 {
            
            DataManager.Instance.setPet(id, data, callback: { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(error.msg)
                    }else{
                        self.view?.doneSuccessfully()
                    }
                }
            })
            
        }else{
            
            DataManager.Instance.register(pet: data, callback: { (error, pet) in
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.view?.endLoadingContent()
                        self.view?.errorMessage(error.msg)
                    }
                }else if self.imageData != nil, let pet = pet {
                    self.saveImatge(petId: pet.id)
                }else{
                    DispatchQueue.main.async {
                        self.view?.endLoadingContent()
                        self.view?.doneSuccessfully()
                    }
                }
            })
            
        }
    }
}

