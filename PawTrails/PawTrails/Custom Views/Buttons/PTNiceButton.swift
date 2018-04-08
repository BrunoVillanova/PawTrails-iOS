//
//  PTNiceButton.swift
//  PawTrails
//
//  Created by Bruno Villanova on 07/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PTNiceButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    fileprivate func setupView() {
        self.circle()
        self.backgroundColor = PTConstants.colors.newRed
        self.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 14)
        self.setTitleColor(.white, for: .normal)
    }
}
