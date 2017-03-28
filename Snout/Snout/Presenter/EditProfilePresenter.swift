//
//  EditProfilePresenter.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol EditProfileView: NSObjectProtocol, View {
    func loadData(user:User, phone:_Phone?, address:_Address?)
    func saved()
}

struct _Phone {
    var number:String
    var code:String
    
    func getJson() -> [String:Any] {
        return ["number" : number, "country_code" : code]
    }
    
    var toString:String {
        
        return "\(code) \(number)"
    }
}

struct _Address {
    var line0:String?
    var line1:String?
    var line2:String?
    var city:String?
    var state:String?
    var postal_code:String?
    var country:String?
    
    init() {
    }
    
    init(from address:Address) {
        self.line0 = address.line0
        self.line1 = address.line1
        self.line2 = address.line2
        self.city = address.city
        self.state = address.state
        self.postal_code = address.postal_code
        self.country = address.country
    }
    
    func getJson() -> [String:Any]? {
        if line0 == nil && line1 == nil && line2 == nil && city == nil && state == nil && postal_code == nil {
            return nil
        }else{
            var out = [String:Any]()
            if line0 != nil { out["line0"] = line0 }
            if line1 != nil { out["line1"] = line1 }
            if line2 != nil { out["line2"] = line2 }
            if city != nil { out["city"] = city }
            if postal_code != nil { out["postal_code"] = postal_code }
            if state != nil { out["state"] = state }
            if country != nil { out["country"] = country }
            return out
        }
    }
    
    var toString: String? {
        
        if let address = self.getJson() as? [String:String] {
            
            if address.count == 0 { return nil }
            
            var desc = [String]()
            if address["line0"] != nil && address["line0"] != "" { desc.append(address["line0"]!)}
            if address["line1"] != nil && address["line1"] != "" { desc.append(address["line1"]!)}
            if address["line2"] != nil && address["line2"] != "" { desc.append(address["line2"]!)}
            if address["city"] != nil && address["city"] != "" { desc.append(address["city"]!)}
            if address["postal_code"] != nil && address["postal_code"] != "" { desc.append(address["postal_code"]!)}
            if address["state"] != nil && address["state"] != "" { desc.append(address["state"]!)}
            if address["country"] != nil && address["country"] != "" { desc.append(address["country"]!)}
            return desc.joined(separator: ", ")
        }
        return nil
        
    }
}

class EditProfilePresenter {
    
    weak private var view: EditProfileView?
    
    private var address:_Address? = nil
    private var phone:_Phone? = nil
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
                self.view?.errorMessage(ErrorMsg(title:"",msg:"\(error)"))
            }else if let user = user {
                
                self.user = user
                
                if let phone = user.phone { self.set(phone: phone.number, phone.country_code) }
                if let address = user.address { self.set(address: _Address(from: address)) }
                
                DispatchQueue.main.async {
                    self.view?.loadData(user: user, phone: self.phone, address: self.address)
                }
            }
        }
    }
    
    func refresh(){
        self.view?.loadData(user: user, phone:phone, address:address)
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
        return Gender.build(code: user.gender)
    }
    
    func getBirthday() -> Date? {
        return user.birthday as Date?
    }
    
    func getPhone() -> _Phone? {
        return phone
    }
    
    func getAddress() -> _Address? {
        return address
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
    
    func set(phone number:String?, _ country_code:String?){
        
        if number == nil || (number != nil && number == "") || country_code == nil || (country_code != nil && country_code == "") {
            self.phone = nil
        }else{
            self.phone = _Phone(number: number!, code: country_code!)
        }
    }
    
    func set(address data:_Address){
        self.address = data
    }
    
    
    func save() {
        
        DataManager.Instance.saveUser(user: user, phone: phone?.getJson(), address: address?.getJson()) { (error, user) in
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
    
    
    func getCountryCodeIndex(countryCode: String) -> Int {
        return CountryCodes.index(where: { (cc) -> Bool in   cc.code == countryCode }) ?? 0
    }
    
    func getCountryCodeIndex(countryShortName: String = DataManager.Instance.getCurrentCountryShortName()) -> Int {
        return CountryCodes.index(where: { (cc) -> Bool in   cc.shortname == countryShortName }) ?? 0
    }
    
    
    
    
    
}

