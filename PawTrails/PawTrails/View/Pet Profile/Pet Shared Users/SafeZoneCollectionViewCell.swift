//
//  SafeZoneCollectionViewCell.swift
//  PawTrails
//
//  Created by Marc Perello on 06/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SafeZoneCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var safeZoneImage: UIImageView!
    @IBOutlet weak var iconeImage: UIImageView!
    @IBOutlet weak var safeZoneNameLabel: UILabel!
    @IBOutlet weak var onSwitcher: UISwitch!

 
    
    override func prepareForReuse() {
        self.safeZoneImage.image = nil
        self.iconeImage.image = nil
        self.safeZoneNameLabel.text = nil
        self.onSwitcher = nil
    }

}
