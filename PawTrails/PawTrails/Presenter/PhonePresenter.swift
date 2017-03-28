//
//  PhonePresenter.swift
//  Snout
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol PhoneView: NSObjectProtocol, View {
    func loadCountryCodes(_ codes:[CountryCode])
    func countryCodesNotFound()
}

class PhonePresenter {
    
    weak fileprivate var view: PhoneView?
    var codes = [CountryCode]()

    func attachView(_ view: PhoneView){
        self.view = view
        getCountryCodes()
    }
    
    func deteachView() {
        self.view = nil
    }
    
    
}

