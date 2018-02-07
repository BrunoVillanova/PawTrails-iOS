//
//  FinishAdventureVC.swift
//  PawTrails
//
//  Created by Marc Perello on 06/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift

class FinishAdventureVC: UIViewController, BEMCheckBoxDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var finishAdventureBtn: UIButton!
    @IBOutlet weak var resumeAdventureBtn: UIButton!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishAdventureBtn.fullyroundedCorner()
        finishAdventureBtn.backgroundColor = UIColor.primary
        resumeAdventureBtn.fullyroundedCorner()
        resumeAdventureBtn.tintColor = UIColor.primary
        resumeAdventureBtn.border(color: UIColor.primary, width: 1.0)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    

    
    @IBAction func finishAdventureBtnPressed(_ sender: Any) {
        self.popUpDestructive(title: "", msg: "Are you sure you want to finish the trip", cancelHandler: nil) { (UIAlertAction) in
            self.showLoadingView()
            DataManager.instance.finishAdventure().subscribe(onNext: { (stoppedTrips) in
                self.hideLoadingView()
                for trip in stoppedTrips {
                    Reporter.debugPrint("TripID \(trip.id) stopped!")
                }
                self.navigationController?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        }
    }
    
    
    @IBAction func resumeAdventureBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

class FinishAdventureCell: UICollectionViewCell {
    @IBOutlet weak var petImageView: UiimageViewWithMask!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var checkBoxView: BEMCheckBox!
}
