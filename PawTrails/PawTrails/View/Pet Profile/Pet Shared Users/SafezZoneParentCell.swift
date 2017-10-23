//
//  SafezZoneParentCell.swift
//  PawTrails
//
//  Created by Marc Perello on 06/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit


class SafezZoneParentCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    let identifier = "safeZoneCell"
    
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
        let nib = UINib(nibName: "SafeZoneCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)

        
        collectionView.contentInset = UIEdgeInsetsMake(20, 0, 80, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 80, 0)
        
        collectionView.reloadData()
    }
    

    
    
    
    
    
  //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let myViewController = parentViewController as? PetProfileCollectionViewController {
            return myViewController.presenter.safezones.count
        } else {
            return 0
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SafeZoneCollectionViewCell
        cell.border(color: .groupTableViewBackground, width: 0.8)
        cell.shadow()
        
        
        if let myViewController = parentViewController as? PetProfileCollectionViewController, let pet = myViewController.pet {
            let safeZone = myViewController.presenter.safezones[indexPath.item]
            
            
            cell.safeZoneNameLabel.text = safeZone.name
            cell.onSwitcher.isOn = safeZone.active
            cell.onSwitcher.tag = indexPath.row
            cell.onSwitcher.addTarget(self, action: #selector(changeSwitchAction(sender:)), for: UIControlEvents.valueChanged)
            cell.onSwitcher.isEnabled = pet.isOwner
            
            
            if let preview = safeZone.preview {
                cell.safeZoneImage.image = UIImage(data: preview as Data)
            }else{
                cell.safeZoneImage.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
            }
            

        }

        return cell

    }
    
    
    
    func changeSwitchAction(sender: UISwitch){
        
        if let myViewController = parentViewController as? PetProfileCollectionViewController, let pet = myViewController.pet {
            
            let safezone = myViewController.presenter.safezones[sender.tag]
            myViewController.presenter.setSafeZoneStatus(id: safezone.id, petId: pet.id, status: sender.isOn) { (success) in
                if !success {
                    sender.isOn = !sender.isOn
                }else if success && sender.isOn {
                    
                    UIApplication.shared.keyWindow?.rootViewController?.popUp(title: "Done", msg: "Safe Zone Has Been Turned On")
                    
                    
                }else if success && !sender.isOn {
                    UIApplication.shared.keyWindow?.rootViewController?.popUp(title: "Done", msg: "Safe Zone Has Been Turned Off")
                }
            }
        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let myViewController = parentViewController as? PetProfileCollectionViewController, let pet = myViewController.pet {
            DispatchQueue.main.async {
                let safeZone = myViewController.presenter.safezones[indexPath.item]
                myViewController.presentEditSafezoneViewController(petId: pet.id, isOwner: pet.isOwner, safeZone: safeZone)

            }
           
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width - 32, height: 250)
    }


    
    
}
