//
//  EditProfilePresenter.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol EditProfileView: NSObjectProtocol, View {
    func emailFormat()
    func loadData(user:User)
    func saved()
}

enum Gender: Int {
    case female = 0,male,undefined
    
    static func count() -> Int {
        return 3
    }
    
    func name() -> String {
        switch self {
        case .female: return "female"
        case .male: return "male"
        default: return "undefined"
        }
    }
    
    func code() -> String? {
        switch self {
        case .female: return "F"
        case .male: return "M"
        default: return nil
        }
    }
    
    init(code:String) {
        switch code {
        case "F": self = .female
        case "M": self = .male
        default: self = .undefined
        }
    }
}

class EditProfilePresenter {
    
    weak fileprivate var view: EditProfileView?
    
    fileprivate var address:[String:String]? = nil
    fileprivate var phone:[String:Any]? = nil
    fileprivate var user:User!
    
    var phoneDescription:String?
    var addressDescription:String?
    
    func attachView(_ view: EditProfileView){
        self.view = view
        getUser()
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
                if user?.phone != nil && user?.phone?.number != nil && user?.phone?.country_code != nil && user?.phone?.country_code?.code != nil {
                    self.setPhone(user!.phone!.number!, user!.phone!.country_code!)
                }
                if user?.address != nil {
                    self.address = user?.address?.toStringDict
                    self.updateAddressDecripton()
                }
                DispatchQueue.main.async {
                    self.view?.loadData(user: user!)
                }
            }
        }
    }
    
    
    func setGender(_ g:Gender){
        user.gender = g.code()
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
    
    func setBirthday(_ date:Date){
        user.birthday = date as NSDate?
    }
    
    func setPhone(_ number:String, _ cc:CountryCode){
        self.phone = [String:Any]()
        self.phone?["number"] = number
        self.phone?["country_code"] = cc.code ?? ""
        self.phoneDescription = cc.code! + " " + number
    }
    
    func setAddress(_ data:[String:String]){
        self.address = data
        updateAddressDecripton()
    }
    
    private func updateAddressDecripton(){
        if self.address == nil { return }
        var desc = [String]()
        if self.address?["line0"] != nil && self.address?["line0"] != "" { desc.append(self.address!["line0"]!)}
        if self.address?["line1"] != nil && self.address?["line1"] != "" { desc.append(self.address!["line1"]!)}
        if self.address?["line2"] != nil && self.address?["line2"] != "" { desc.append(self.address!["line2"]!)}
        if self.address?["city"] != nil && self.address?["city"] != "" { desc.append(self.address!["city"]!)}
        if self.address?["postal_code"] != nil && self.address?["postal_code"] != "" { desc.append(self.address!["postal_code"]!)}
        if self.address?["state"] != nil && self.address?["state"] != "" { desc.append(self.address!["state"]!)}
        if self.address?["country"] != nil && self.address?["country"] != "" { desc.append(self.address!["country"]!)}
        self.addressDescription = desc.joined(separator: ", ")
    }
    
    func save(_ name:String?,_ surname:String?,_ email:String?) {
        user.name = name
        user.surname = surname
        user.email = email
        DataManager.Instance.saveUser(user: user, phone: phone, address: address) { (error, user) in
            if error == nil {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.view?.saved()
                })
            }

        }
    }



















}

