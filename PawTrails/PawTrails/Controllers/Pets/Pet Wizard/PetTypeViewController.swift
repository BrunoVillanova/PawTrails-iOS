//
//  PetTypeViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 30/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PetTypeViewController: PetWizardStepViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let petTypes = Variable(["Dog", "Cat", "Bunny", "Bird", "Hamster", "Other"])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 150, height: 150)
        }
        
        petTypes.asObservable().bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: PetTypeCollectionViewCell.self)) { (row, petTypeTitle, cell) in
            cell.configure(petTypeTitle)
        }.disposed(by: disposeBag)
        
        Observable
            .zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(String.self))
            .bind { [unowned self] indexPath, petTypeTitle in
                let cell = self.collectionView.cellForItem(at: indexPath) as! PetTypeCollectionViewCell
                cell.isSelected = false
                cell.selectCell()
            }
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class PetTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var petPhotoImageView: UIImageView!
    @IBOutlet weak var petTypeTitleLabel: UILabel!
    
    func configure(_ petTypeTitle: String) {
        let petImage = UIImage(named: petTypeTitle)
        petPhotoImageView.image = petImage
        petTypeTitleLabel.text = petTypeTitle
    }
    
    func selectCell(_ animated: Bool = true) {
        UIView.animate(withDuration: 0.3, animations: {
            self.petPhotoImageView.alpha = 0.3
            self.petTypeTitleLabel.alpha = 0.3
        }, completion: { finished in
            if finished {
                UIView.animate(withDuration: 0.3, animations: {
                    self.petPhotoImageView.alpha = 1
                    self.petTypeTitleLabel.alpha = 1
                })
            }
        })
    }
}
