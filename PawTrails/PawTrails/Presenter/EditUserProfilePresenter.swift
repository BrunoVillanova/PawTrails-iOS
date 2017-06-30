//
//  EditUserProfilePresenter.swift
//  PawTrails
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol EditUserProfileView: NSObjectProtocol, View, LoadingView {
    func loadData()
    func saved()
}

class EditUserProfilePresenter {
    
    weak private var view: EditUserProfileView?
    
    var user: User!
    var imageData: Data? = nil
    var CountryCodes = [CountryCode]()

    func attachView(_ view: EditUserProfileView, _ user:User?){
        self.view = view
        self.user = user
        self.view?.loadData()
        getCountryCodes()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func refresh(){
        self.view?.loadData()
    }
    
    func set(phone number:String?, _ country_code:String?){
        
        if let number = number, let country_code = country_code {
            if user.phone == nil {
                user.phone = Phone(number: number, countryCode: country_code)
            }else{
                user.phone?.number = number
                user.phone?.countryCode = country_code
            }
        }else{
            user.phone = nil
        }
    }
    
    func set(image data:Data){
        imageData = data
    }
    
    func socialMediaLoggedIn() -> Bool {
        return SharedPreferences.has(.socialnetwork)
    }
    
    func save() {

        if let imageData = imageData {
            save(imatge: imageData)
        }else{
            saveProfile()
        }
    }
    
    func save(imatge: Data){
        
        view?.beginLoadingContent()
        
        DataManager.Instance.saveUser(image: imatge) { (error) in
            if let error = error {
                self.view?.endLoadingContent()
                self.view?.errorMessage(error.msg)
            }else{
                self.imageData = nil
                self.saveProfile()
            }
        }
    }
    
    func saveProfile(){
        
        DataManager.Instance.save(user) { (error, user) in
            
            self.view?.endLoadingContent()
            if let error = error {
                self.view?.errorMessage(error.msg)
            }else{
                self.view?.saved()
            }
        }
    }

    // Helpers
    
    func getCountryCodes(){
        DataManager.Instance.getCountryCodes { (cc) in
            if let cc = cc {
                self.CountryCodes = cc
            }else{
                debugPrint("No CC")
            }

        }
    }

    func getCountryCodeIndex(countryCode: String) -> Int {
        return CountryCodes.index(where: { (cc) -> Bool in   cc.code == countryCode }) ?? 0
    }
    
    func getCountryCodeIndex(countryShortName: String) -> Int {
        return CountryCodes.index(where: { (cc) -> Bool in   cc.shortName == countryShortName }) ?? 0
    }
    
    func getCurrentCountryCodeIndex() -> Int {
        let current = DataManager.Instance.getCurrentCountryShortName()
        return CountryCodes.index(where: { (cc) -> Bool in   cc.shortName == current }) ?? 0
    }
    

    
    
}
