//
//  PetInfromationCell.swift
//  PawTrails
//
//  Created by Marc Perello on 23/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetInfromationCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumLineSpacing = 0
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    

    
    override func setupViews() {
        

        
        addSubview(collectionView)

        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        let nib = UINib(nibName: "ShareCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "myCell")
        
        let secondNib = UINib(nibName: "PetProfileCollectionViewCell", bundle: nil)
        collectionView.register(secondNib, forCellWithReuseIdentifier: "cell")
        collectionView.reloadData()

}


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            
            if let myCollectionView = parentViewController as? PetProfileCollectionViewController {
                return  myCollectionView.presenter.users.count
                
            } else {
                return 0
            }

        }
        
}

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let section = indexPath.section
        
        
        if section == 0 {
            
            let secondCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PetProfileCollectionViewCell
            if let myCollectionView = parentViewController as? PetProfileCollectionViewController, let pet =  myCollectionView.pet {
            secondCell.petBirthdayLabel.text = pet.birthday?.toStringShow
            secondCell.typeLabel.text = pet.typeString
            secondCell.breedLabel.text = pet.breedsString
            secondCell.genderLabel.text = pet.gender?.name
            secondCell.weightLabel.text = pet.weightString
            secondCell.backgroundColor = UIColor.white
            secondCell.petName.text = pet.name
            if let imageData = pet.image {
                secondCell.petImage.image = UIImage(data: imageData as Data)
                
            }
            }
            
            return secondCell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ShareCollectionViewCell
            if let myCollectionView = parentViewController as? PetProfileCollectionViewController, let _ =  myCollectionView.pet {
                let user = myCollectionView.presenter.users[indexPath.item]
                cell.emailLabel.text = user.email
                let fullName = "\(user.name ?? "") \(user.surname ?? "")"
                cell.nameLabel.text = fullName
                cell.nameLabel.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
                let imageData = user.image ?? Data()
                cell.userProfileImage.image = UIImage(data: imageData)
                cell.deleteButton.tag = indexPath.row
                cell.deleteButton.addTarget(self, action: #selector(removeBtnPressed), for: .touchUpInside)
                cell.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
            }
            return cell

        }
 
}

    func removeBtnPressed(sender: UIButton?) {
    
        if let myCollectionView = parentViewController as? PetProfileCollectionViewController, let pet =  myCollectionView.pet {
            let selectedUser = myCollectionView.presenter.users[(sender?.tag)!]
            let owner = pet.owner
            let appuser = Int(SharedPreferences.get(.id))
            
            
            if appuser == owner?.id && appuser != selectedUser.id {
                // Owner Remove that user
                self.popUpDestructive(title: "Remove \(selectedUser.name ?? "this user") from \(pet.name ?? "this pet")", msg: "If you proceed you will remove this user from the pet sharing list.", cancelHandler: nil, proceedHandler: { (remove) in
                    myCollectionView.presenter.removePetUser(with: selectedUser.id, from: pet.id)
                })
                
                
            }
            
            
        }
}

    
    func popUpDestructive(title:String, msg:String, cancelHandler: ((UIAlertAction)->Void)?, proceedHandler: ((UIAlertAction)->Void)?){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
        alert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: proceedHandler))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 0, 0, 0)
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        if section == 0 {
            return CGSize(width: self.frame.width, height: self.frame.height - 150)
        } else {
            return CGSize(width: self.frame.width, height: 90)

        }
        
    }

    
    
}



