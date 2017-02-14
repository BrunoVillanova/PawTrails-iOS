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

extension String {
    
    public var isValidEmail:Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailTest.evaluate(with: self)
    }
    

    public var isValidPassword:Bool {
        let lower = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
        let upper = CharacterSet(charactersIn: "ABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        let numbers = CharacterSet(charactersIn: "0123456789")
//        let special = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789").inverted
        return self.rangeOfCharacter(from: lower) != nil && self.rangeOfCharacter(from: upper) != nil && self.rangeOfCharacter(from: numbers) != nil && self.characters.count > 7
    }
    
}
