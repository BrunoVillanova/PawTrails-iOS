//
//  FinishAdventureVC.swift
//  PawTrails
//
//  Created by Marc Perello on 06/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class FinishAdventureVC: UIViewController, BEMCheckBoxDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var finishAdventureBtn: UIButton!
    @IBOutlet weak var resumeAdventureBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishAdventureBtn.fullyroundedCorner()
        finishAdventureBtn.backgroundColor = UIColor.primary
        
        
        resumeAdventureBtn.fullyroundedCorner()
        resumeAdventureBtn.tintColor = UIColor.primary
        resumeAdventureBtn.border(color: UIColor.primary, width: 1.0)
        
        

        // Do any additional setup after loading the view.
    }

    @IBAction func finishAdventureBtnPressed(_ sender: Any) {
        
        
    }
    @IBAction func resumeAdventureBtnPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
  
}

class FinishAdventureCell: UICollectionViewCell {
    
    @IBOutlet weak var petImageView: UiimageViewWithMask!
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var checkBoxView: BEMCheckBox!
}
