//
//  PTGradientView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 07/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PTGradientView: UIView {
    
    let gradient: CAGradientLayer = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    fileprivate func setupView() {
        self.isOpaque = false
        self.backgroundColor = .clear
        
        let startingColor = UIColor(white: 0, alpha: 0.05)
        gradient.colors = [startingColor.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0 , 0.75]
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
    }
}
