//
//  PTWideButton.swift
//  PawTrails
//
//  Created by Bruno Villanova on 10/12/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTWideButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    fileprivate func setupView() {
        self.fullyroundedCorner()
        self.backgroundColor = UIColor.primary
        self.tintColor = UIColor.secondary
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        if let currentTitle = self.title(for: .normal) {
            self.setTitle(currentTitle.uppercased(), for: .normal)
        }
    }
    
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        let finalTitle = title?.uppercased()
        super.setTitle(finalTitle, for: state)
    }
}
