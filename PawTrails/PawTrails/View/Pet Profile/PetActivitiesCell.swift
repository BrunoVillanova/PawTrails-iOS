//
//  PetActivitiesCell.swift
//  PawTrails
//
//  Created by Marc Perello on 11/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetActivitiesCell: UICollectionViewCell {

    @IBOutlet weak var restingView: CircleChart!
    @IBOutlet weak var normalView: CircleChart!
    @IBOutlet weak var playingView: CircleChart!
    @IBOutlet weak var adventureView: CircleChart!
    
    @IBOutlet weak var livelyView: CircleChart!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
