//
//  SettingsView.swift
//  PawTrails
//
//  Created by Marc Perello on 09/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import YNDropDownMenu
import SkyFloatingLabelTextField

class SettingsViews: YNDropDownView {
    
    @IBOutlet var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var circleBtn: UIButton!
    @IBOutlet weak var squareBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var collectionView: UICollectionView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        circleBtn.backgroundColor = UIColor.brown
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initViews()
    }
    
    override func dropDownViewOpened() {
       self.changeMenu(title: "Hide SafeZone Settings", at: 0)
        
    }
    
    override func dropDownViewClosed() {
        self.changeMenu(title: "Show SafeZone Settings", at: 0)

    }
    
    
    
    func initViews() {
    }

    
}
