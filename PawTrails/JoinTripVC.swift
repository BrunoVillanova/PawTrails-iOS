//
//  JoinTripVC.swift
//  PawTrails
//
//  Created by Marc Perello on 07/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class JoinTripVC: UIViewController {
    @IBOutlet weak var joinAdventureBtn: UIButton!

    @IBOutlet weak var petsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        joinAdventureBtn.fullyroundedCorner()
        joinAdventureBtn.backgroundColor = UIColor.primary

        joinAdventureBtn.titleLabel?.textColor = UIColor.secondary
    }

   
    @IBAction func joinAdventureBtnPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    

    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
     
    }
}


class JoinPetCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var petImage: UiimageViewWithMask!
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var petName: UILabel!
}
