//
//  UiimageViewWithMask.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 01/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit


// Mohmed -- To allow using mask in the storyboard.


@IBDesignable
class UiimageViewWithMask: UIImageView {
    
    var maskImageView = UIImageView()
    
    @IBInspectable    
    var maskImage: UIImage? {
        didSet {
            
            maskImageView.image = maskImage
            maskImageView.frame = bounds
            mask = maskImageView
        }
    }
}
