//
//  AddressPresenter.swift
//  Snout
//
//  Created by Marc Perello on 20/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol AddressView: NSObjectProtocol, View {
    func loadCountries(_ codes:[CountryCode])
    func countriesNotFound()
}

class AddressPresenter {
    
    weak fileprivate var view: AddressView?
    
    func attachView(_ view: AddressView){
        self.view = view
        self.getCountryCodes()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    func getCountryCodes(){
        if let codes = DataManager.Instance.getCountryCodes() {
            self.view?.loadCountries(codes)
        }else{
            self.view?.countriesNotFound()
        }
    }
}

