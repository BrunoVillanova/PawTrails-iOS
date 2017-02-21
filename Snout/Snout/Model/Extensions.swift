//
//  Extensions.swift
//  Snout
//
//  Created by Marc Perello on 21/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

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


// MARK:- View

public enum notificationType{
    case red, blue, green
}

extension UIViewController {
    
    func alert(title:String, msg:String, actionTitle: String = "Ok"){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func round() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
}
