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
    
    
    private var address:_Address? = nil
    private var phone:_Phone? = nil
    private var imageData: Data? = nil
    
    private var data = [String:Any]()
    
    var CountryCodes = [CountryCode]()
    
    func attachView(_ view: EditUserProfileView, _ user:User?){
        self.view = view
        
        load(user)
        getCountryCodes()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    
    
    fileprivate func load(_ user: User?) {
        
        if let user = user {
            
            self.data = user.toDict
            
            if let phone = user.phone { self.set(phone: phone.number, phone.country_code) }
            if let address = user.address { self.set(address: _Address(from: address)) }
            
            DispatchQueue.main.async {
                self.view?.loadData()
            }
            
        }else{
            self.view?.errorMessage(ErrorMsg(title:"",msg:"couldn't load user"))
        }
    }
    
    func refresh(){
        self.view?.loadData()
    }
    
    //MARK:- Getters
    
    func getName() -> String? {
        return data["name"] as? String
    }
    
    func getSurName() -> String? {
        return data["surname"] as? String
    }
    
    func getEmail() -> String? {
        return data["email"] as? String
    }
    
    func getGender() -> Gender? {
        if let code = data["gender"] as? Int16 { return Gender(rawValue: code) }
        return nil
    }
    
    func getBirthday() -> Date? {
        return data["birthday"] as? Date
    }
    
    func getPhone() -> _Phone? {
        return phone
    }
    
    func getAddress() -> _Address? {
        return address
    }
    
    func getImage() -> Data? {
        return data["image"] as? Data
    }
    
    func socialMediaLoggedIn() -> Bool {
        return data["socialNetwork"] != nil
    }
    
    //MARK:- Setters
    
    func set(name: String?) {
        data["name"] = name ?? ""
    }
    
    func set(surname: String?) {
        data["surname"] = surname ?? ""
    }
    
    func set(email: String?) {
        data["email"] = email ?? ""
    }
    
    func set(gender:Gender?){
        data["gender"] = gender?.code ?? ""
    }
    
    func set(birthday:Date?){
        data["birthday"] = birthday ?? ""
    }
    
    func set(phone number:String?, _ country_code:String?){
        
        if let number = number, let country_code = country_code {
            self.phone = _Phone(number: number, code: country_code)
        }else{
            self.phone = nil
        }
    }
    
    func set(address data:_Address){
        self.address = data
    }
    
    func set(image data:Data){
        imageData = data
    }
    
    
    func save() {

        
            view?.beginLoadingContent()
            if let imageData = imageData {
                var data = [String:Any]()
                data["path"] = "user"
                data["userid"] = SharedPreferences.get(.id)
                data["picture"] = imageData
                
                DataManager.Instance.set(image: data, callback: { (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view?.endLoadingContent()
                            self.view?.errorMessage(error.msg)
                        }
                    }else{
                        self.imageData = nil
                        self.save()
                    }
                })
            }else{
                data["date_of_birth"] = (data["birthday"] as! Date?)?.toStringServer ?? ""
                data.filter(by: ["image", "imageURL", "birthday"])
                data["mobile"] = phone?.getJson()
                data["address"] = address?.getJson()
                data["gender"] = getGender()?.code ?? ""
                
                DataManager.Instance.save(user: data) { (error, user) in
                    DispatchQueue.main.async {
                        self.view?.endLoadingContent()
                        if let error = error {
                            self.view?.errorMessage(error.msg)
                        }else{
                            self.view?.saved()
                        }
                    }
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

