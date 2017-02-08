//
//  InitialPresenter.swift
//  Snout
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol InitialView: NSObjectProtocol, View {
}

class InitialPresenter {
    
    weak fileprivate var initialView: InitialView?
    
    func attachView(_ view: InitialView){
        self.initialView = view
    }
    
    func deteachView() {
        self.initialView = nil
    }
    
}
