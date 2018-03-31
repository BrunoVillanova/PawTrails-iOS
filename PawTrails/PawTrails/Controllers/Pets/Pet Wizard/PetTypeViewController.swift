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
        
//        petTypes.asObservable().bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: PetTypeCollectionViewCell.self)) { (row, petTypeTitle, cell) in
//            var selected = false
//
//            if let petType = self.pet!.type?.type?.code {
//                selected = petTypeTitle.lowercased() == petType
//            }
//            cell.configure(petTypeTitle, selected: selected)
//        }.disposed(by: disposeBag)
        
        Observable
            .zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(String.self))
            .bind { [unowned self] indexPath, petTypeTitle in
                let cell = self.collectionView.cellForItem(at: indexPath) as! PetTypeCollectionViewCell
                cell.isSelected = false
                cell.selectCell()
                if petTypeTitle.lowercased() != "other" {
                    self.pet!.type = PetType(type: Type.build(code: petTypeTitle.lowercased()), description: petTypeTitle)
                    self.delegate?.stepCompleted(completed: true, pet: self.pet!)
                    self.delegate?.goToNextStep()
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        petTypes.asObservable().bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: PetTypeCollectionViewCell.self)) { (row, petTypeTitle, cell) in
            var selected = false
            
            if let petType = self.pet!.type?.type?.code {
                selected = petTypeTitle.lowercased() == petType
            }
            cell.configure(petTypeTitle, selected: selected)
            }.disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func nextButtonVisible() -> Bool {
        return self.pet!.type != nil
    }
}

class PetTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var petPhotoImageView: UIImageView!
    @IBOutlet weak var petTypeTitleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    func configure(_ petTypeTitle: String, selected: Bool) {
        mainView.layer.cornerRadius = 10
        let petImage = UIImage(named: petTypeTitle)
        petPhotoImageView.image = petImage
        petTypeTitleLabel.text = petTypeTitle
        setSelectedStyle(selected)
    }
    
    func setSelectedStyle(_ selected: Bool) {
        if selected {
            petTypeTitleLabel.font = UIFont(name: "Monserrat-Medium", size: petTypeTitleLabel.font.pointSize)
            petTypeTitleLabel.textColor = .white
            mainView.backgroundColor = PTConstants.colors.newRed
        } else  {
            petTypeTitleLabel.font = UIFont(name: "Monserrat-Regular", size: petTypeTitleLabel.font.pointSize)
            petTypeTitleLabel.textColor = PTConstants.colors.darkGray
            mainView.backgroundColor = .clear
        }
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
