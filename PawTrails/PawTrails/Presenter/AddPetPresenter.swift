//
//  AddPetPresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 12/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation


struct Weight {
    enum massUnit: String {
        case kg = "kg", lbs = "lbs"
    }

    var unit: massUnit
    var amount: Double
    
    func toString() -> String {
        return "\(amount) \(unit.rawValue)"
    }
}

struct _pet {
    var deviceCode: String?
    var name: String?
    var type: String?
    var gender: Gender?
    var breed: String?
    var birthday: Date?
    var weight: Weight?
    var imageData: Data?
}

protocol AddPetView: NSObjectProtocol, View {
    func load(pet:_pet)
    func created()
}


class AddPetPresenter {
    
    weak private var view: AddPetView?
    
    private var pet:_pet!
    
    var CountryCodes = [CountryCode]()
    
    func attachView(_ view: AddPetView){
        self.view = view
        pet = _pet()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    
    //MARK:- Getters
    
    func getName() -> String? {
        return pet.name
    }
    
    func getType() -> String? {
        return pet.type
    }
    
    func getGender() -> Gender? {
        return pet.gender
    }
    
    func getBreed() -> String? {
        return pet.breed
    }
    
    func getBirthday() -> Date? {
        return pet.birthday
    }
    
    func getWeight() -> Weight? {
        return pet.weight
    }
    
    //MARK:- Setters
    
    func set(deviceCode: String?) {
        pet.deviceCode = deviceCode
    }
    
    func set(name: String?) {
        pet.name = name
        print(pet.name ?? "No name found")
    }
    
    func set(type: String?) {
        pet.type = type
    }
    
    func set(gender:Gender?){
        pet.gender = gender
    }

    func set(breed: String?) {
        pet.breed = breed
    }
    
    func set(birthday:Date?){
        pet.birthday = birthday
    }
    
    func set(weight:Weight?){
        pet.weight = weight
    }
    
    func set(imageData:Data?){
        pet.imageData = imageData
    }
    
    
    func refresh(){
        self.view?.load(pet: pet)
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

