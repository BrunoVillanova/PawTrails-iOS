//
//  EditProfilePresenter.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol EditProfileView: NSObjectProtocol, View {
    func loadData(user:User)
    func saved()
}

class EditProfilePresenter {
    
    weak private var view: EditProfileView?
    
    private var address:[String:String]? = nil
    private var phone:[String:Any]? = nil
    private var user:User!
    
    var CountryCodes = [CountryCode]()
    
    func attachView(_ view: EditProfileView){
        self.view = view
        getUser()
        getCountryCodes()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    fileprivate func getUser() {
        
        DataManager.Instance.getUser { (error, user) in
            
            if error != nil {
                self.view?.errorMessage(errorMsg("","\(error)"))
            }else if user != nil {
                
                self.user = user
                
                if let phone = user?.phone { self.set(phone: phone.number, phone.country_code) }
                if let address = user?.address { self.set(address: address.toStringDict) }
                
                DispatchQueue.main.async {
                    self.view?.loadData(user: user!)
                }
            }
        }
    }
    
    //MARK:- Getters
    
    func getName() -> String? {
        return user.name
    }
    
    func getSurName() -> String? {
        return user.surname
    }
    
    func getEmail() -> String? {
        return user.email
    }
    
    func getGender() -> Gender? {
        return Gender(code: user.gender)
    }
    
    func getBirthday() -> Date? {
        return user.birthday as Date?
    }
    
    func getPhone() -> Phone? {
        return user.phone
    }
    
    func getAddress() -> Address? {
        return user.address
    }
    
    //MARK:- Setters
    
    func set(name: String?) {
        user.name = name
    }
    
    func set(surname: String?) {
        user.surname = surname
    }
    
    func set(email: String?) {
        user.email = email
    }
    
    func set(gender:Gender?){
        user.gender = gender?.code
    }
    
    func set(birthday:Date?){
        user.birthday = birthday as NSDate?
    }
    
    func set(phone number:String?, _ cc:CountryCode?){
        
        guard let number = number else {
            return
        }
        guard let cc = cc else {
            return
        }
        self.phone = [String:Any]()
        self.phone?["number"] = number
        self.phone?["country_code"] = cc.code ?? ""
    }
    
    func set(address data:[String:String]){
        self.address = data
    }
    
    
    func save() {
        DataManager.Instance.saveUser(user: user, phone: phone, address: address) { (error, user) in
            if error == nil {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.view?.saved()
                })
            }
        }
    }

    // Helpers
    
    func getCountryCodes(){
        if let cc = DataManager.Instance.getCountryCodes() {
            CountryCodes = cc
        }else{
            debugPrint("No CC")
        }
    }
    
    func getCountryCodeIndex(countryShortName: String = DataManager.Instance.getCurrentCountryShortName()) -> Int {
        return CountryCodes.index(where: { (cc) -> Bool in   cc.shortname == countryShortName }) ?? 0
    }

    
    
    
    
}

