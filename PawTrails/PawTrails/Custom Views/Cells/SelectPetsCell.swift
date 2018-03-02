//
//  SelectPetsCell.swift
//  PawTrails
//
//  Created by Marc Perello on 04/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit


class SelectPetsCell: UICollectionViewCell {
    @IBOutlet weak var petImage: PTBalloonImageView!
    @IBOutlet weak var petTitle: UILabel!
    @IBOutlet weak var checkMarkView: BEMCheckBox!
    
    override func awakeFromNib() {
        checkMarkView.setOn(false, animated: false)
    }
    
    override func prepareForReuse() {
        petTitle.text = nil
        petImage.image = nil
        checkMarkView.setOn(false, animated: false)
    }
    
    func configureWithPet(_ pet: Pet) {
        petTitle.text = pet.name
        petImage.imageUrl = pet.imageURL
    }
}
