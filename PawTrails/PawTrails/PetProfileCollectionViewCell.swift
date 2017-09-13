//
//  PetProfileCollectionViewCell.swift
//  PawTrails
//
//  Created by Marc Perello on 08/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetProfileCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var petImage: UiimageViewWithMask!
    
    @IBOutlet weak var petName: UILabel!
    
    @IBOutlet weak var petBirthdayLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var breedLabel: UILabel!
    
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    
  
    @IBOutlet weak var reportLostBtn: UIButton!

    override func awakeFromNib() {

        reportLostBtn.fullyroundedCorner()
        reportLostBtn.backgroundColor = UIColor.primary
    }
    
    @IBAction func reportLostPressed(_ sender: Any) {
        
        }

    
}
