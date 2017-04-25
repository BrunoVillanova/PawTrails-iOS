//
//  Fence.swift
//  PawTrails
//
//  Created by Marc Perello on 24/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation

class Fence: NSObject {
    
    let layer: CALayer
    var isCircle:Bool {
        didSet {
            updateCornerRadius()
        }
    }
    
    init(frame: CGRect, isCircle:Bool) {
        layer = CALayer()
        layer.frame = frame
        layer.backgroundColor =  UIColor.blueSystem().withAlphaComponent(0.5).cgColor
        self.isCircle = isCircle
    }
    
    func setFrame(_ frame:CGRect) {
        layer.frame = frame
        updateCornerRadius()
    }
    
    private func updateCornerRadius(){
        layer.cornerRadius = isCircle ? layer.frame.width / 2.0 : 0.0
    }
    
    var x0: CGFloat { return layer.frame.origin.x }
    var y0: CGFloat { return layer.frame.origin.y }
    var xf: CGFloat { return x0 + layer.frame.width }
    var yf: CGFloat { return y0 + layer.frame.height }
}
