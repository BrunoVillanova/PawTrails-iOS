//
//  AllowedCharsTextField.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 31/01/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//



import UIKit



class AllowedCharsTextField: UITextField, UITextFieldDelegate {
    

    @IBInspectable var allowedChars: String = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        autocorrectionType = .no
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count > 0 else {
            return true
        }
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return prospectiveText.contains(allowedChars)
    }
    
}
