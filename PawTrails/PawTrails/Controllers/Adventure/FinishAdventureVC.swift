//
//  FinishAdventureVC.swift
//  PawTrails
//
//  Created by Marc Perello on 06/09/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GSMessages

protocol FinishAdventureVCDelegate {
    func adventureFinished(viewController: FinishAdventureVC, trips: [Trip]?)
    func adventureResumed(viewController: FinishAdventureVC, trips: [Trip]?)
}

class FinishAdventureVC: UIViewController, BEMCheckBoxDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var finishAdventureBtn: UIButton!
    @IBOutlet weak var resumeAdventureBtn: UIButton!
    
    var trips: [Trip]?
    let disposeBag = DisposeBag()
    var delegate: FinishAdventureVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    fileprivate func initialize() {
        
        DataManager.instance.pets().bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: FinishAdventureCell.self)) { (row, element, cell) in
            cell.configureWithPet(element)
        }.disposed(by: disposeBag)
        configureLayout()
    }
    
    fileprivate func configureLayout() {
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
                self.delegate?.adventureFinished(viewController: self, trips: stoppedTrips)
                
            }, onError: { (error) in
                let errorMessage = "Error trying to finish adventure"
                self.showMessage(errorMessage, type: .error)
            }).disposed(by: self.disposeBag)
        }
    }
    
    
    @IBAction func resumeAdventureBtnPressed(_ sender: Any) {
        self.delegate?.adventureResumed(viewController: self, trips: trips)
    }
}

class FinishAdventureCell: UICollectionViewCell {
    @IBOutlet weak var petImageView: PTBalloonImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var checkBoxView: BEMCheckBox!
    
    func configureWithPet(_ pet: Pet) {
        petNameLabel.text = pet.name
        petImageView.imageUrl = pet.imageURL
    }
}
