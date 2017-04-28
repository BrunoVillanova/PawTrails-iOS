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
    
    func getType() -> Type? {
        if let code = data["type"] as? Int16 {
            return Type(rawValue: Int(code))
        }
        return nil
    }
    
    func getTypeDescription() -> String? {
        return data["type_descr"] as? String
    }
    
    func getTypeText() -> String? {
        if let type = getType() {
            if let description = getTypeDescription() { return type.name + " - " + description }
            return type.name
        }
        return nil
    }
    
    func getGender() -> Gender? {
        if let code = data["gender"] as? Int16 {
            return Gender(rawValue: Int(code))
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
        return data["otherBreed"] as? String
    }
    
    func getOtherBreed() -> String? {
        return data["otherBreed"] as? String
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
        data["deviceCode"] = deviceCode ?? ""
    }
    
    func set(name: String?) {
        data["name"] = name ?? ""
    }
    
    func set(type: Type?) {
        data["type"] = type?.rawValue.toInt16 ?? ""
    }
    
    func set(typeDescription: String?) {
        data["type_descr"] = typeDescription ?? ""
    }
    
    func set(gender:Gender?){
        data["gender"] = gender?.rawValue.toInt16 ?? ""
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
        data["otherBreed"] = otherBreed ?? ""
    }
    
    func set(birthday:Date?){
        data["birthday"] = birthday ?? ""
    }
    
    func set(weight:Weight?){
        data["weight"] = weight ?? ""
    }
    
    func set(imageData:Data?){
        data["image"] = imageData ?? ""
    }
    
    func set(neutred:Bool?){
        data["neutred"] = neutred ?? ""
    }
    
    func refresh(){
        view?.loadPet()
    }
    
    func done(){
        
        view?.beginLoadingContent()
        
        data["date_of_birth"] = (data["birthday"] as! Date?)?.toStringServer ?? ""
        data["weight"] = (data["weight"] as! Weight?)?.amount ?? ""
        data["breed_descr"] = data["otherBreed"] ?? ""
        
        data["type"] = getType()?.code ?? ""
        data["gender"] = getGender()?.code ?? ""
        
        data.filter(by: ["image", "imageURL", "birthday"])
        
        if editMode, let id = data["id"] as? String {
            
            
            DataManager.Instance.setPet(id, data, callback: { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if let error = error {
                        self.view?.errorMessage(ErrorMsg(title: "Error", msg: "\(error)"))
                    }else{
                        self.view?.doneSuccessfully()
                    }
                }
            })
            
        }else{

            data["device_code"] = data["deviceCode"]
            data.removeValue(forKey: "deviceCode")

            DataManager.Instance.register(pet: data, callback: { (error) in
                DispatchQueue.main.async {
                    self.view?.endLoadingContent()
                    if error == nil {
                        self.view?.doneSuccessfully()
                    }else{
                        self.view?.errorMessage(ErrorMsg(title: "", msg: ""))
                    }
                }
            })
        }
    }
}

