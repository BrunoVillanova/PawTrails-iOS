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
    
    fileprivate var address:[String:Any]? = nil
    fileprivate var phone:[String:Any]? = nil
    fileprivate var user:User!
    
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
                self.view?.loadData(user: user!)
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
        self.phone = [
            "number":number,
            "country_code":cc.code ?? ""
        ]
    }
    
    func setAddress(_ data:[String:Any]){
        self.address = data
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

