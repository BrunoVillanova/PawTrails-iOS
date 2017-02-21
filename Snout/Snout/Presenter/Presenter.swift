//
//  Presenter.swift
//  Snout
//
//  Created by Marc Perello on 08/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

protocol View {
    func errorMessage(_ error:errorMsg)
}

protocol ConnectionView {
    func connectedToNetwork()
    func notConnectedToNetwork()
}


