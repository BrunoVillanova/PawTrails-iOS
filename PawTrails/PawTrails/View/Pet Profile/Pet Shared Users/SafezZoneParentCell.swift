//
//  SafezZoneParentCell.swift
//  PawTrails
//
//  Created by Marc Perello on 06/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit


class SafezZoneParentCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SazeZoneView {
    
    
    let identifier = "safeZoneCell"
    
    
    
    var pet = PetId.petId
    fileprivate let presenter = SazeZonePresnter()
    
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
     

        presenter.attacheView(self, pet: pet)
//        self.presenter.getPet(with: self.pet.id)
        
        load(pet)
        reloadPetInfo()
        reloadSafeZones()

        
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        let nib = UINib(nibName: "SafeZoneCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)

        
        collectionView.contentInset = UIEdgeInsetsMake(20, 0, 80, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 80, 0)
        
        
    }
    
    deinit {
        presenter.deteachView()
    }
    
    func reloadPetInfo() {
        presenter.loadPet(with: pet.id)
    }
    
    
    
    
    
    
    
    func loadSafeZones() {
        pet.safezones = presenter.safeZones
        if self.presenter.safeZones.count == 0 { return }
        let safezonesGroup = DispatchGroup()
        
        for safezone in self.presenter.safeZones {
            // Address
            if safezone.address == nil {
                
                guard let center = safezone.point1 else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No center point found!")
                    break
                }
                GeocoderManager.Intance.reverse(type: .safezone, with: center, for: safezone.id)
            }
            // Map
            if safezone.preview == nil {
                guard let center = safezone.point1?.coordinates else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No center point found!")
                    continue
                }
                guard let topCenter = safezone.point2?.coordinates else {
                    Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "No topcenter point found!")
                    continue
                }
                
                safezonesGroup.enter()
                Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "map", safezone.id)
                self.buildMap(center: center, topCenter: topCenter, shape: safezone.shape, handler: { (image) in
                    if let image = image, let data = UIImagePNGRepresentation(image) {
                        Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "released", safezone.id)
                        self.presenter.set(imageData: data, for: safezone.id) { (errorMsg) in
                            if let errorMsg = errorMsg {
                                self.errorMessage(errorMsg)
                            }
                            safezonesGroup.leave()
                        }
                    }
                })
            }
        }
        
        safezonesGroup.notify(queue: .main, execute: {
            self.presenter.getPet(with: self.pet.id)
            
        })
    }
    
    
    func buildMap(center: CLLocationCoordinate2D, topCenter: CLLocationCoordinate2D, shape: Shape, handler: @escaping ((UIImage?)->())){
        if CLLocationCoordinate2DIsValid(center) && CLLocationCoordinate2DIsValid(topCenter) {
            SnapshotMapManager.Intance.performSnapShot(with: center, topCenter: topCenter, shape: shape, handler: { (image) in
                handler(image)
            })
        }else{
            self.errorMessage(ErrorMsg.init(title: "", msg: "wrong coordinates"))
            handler(nil)
        }
    }
    
    
    
    //MARK: - SafeZoneView
    func errorMessage(_ error: ErrorMsg) {
        UIApplication.shared.keyWindow?.rootViewController?.self.alert(title: error.title, msg: error.msg)


        print(error.title)
    }
    
    
    func load(_ pet: Pet) {
        self.pet = pet
//        navigationItem.title = pet.name
        collectionView.reloadData()

        
    }
    
    
    func reloadSafeZones() {
        presenter.loadSafeZones(for: pet.id)
    }

    
    func petNotFound() {
        UIApplication.shared.keyWindow?.rootViewController?.alert(title: "", msg: "couldn't load pet")

    }
    


//    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.safeZones.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SafeZoneCollectionViewCell
        cell.border(color: .groupTableViewBackground, width: 0.8)
        cell.shadow()
        
        
        let safezone = presenter.safeZones[indexPath.item]
        cell.safeZoneNameLabel.text = safezone.name
        cell.onSwitcher.isOn = safezone.active
        cell.onSwitcher.tag = indexPath.row
        cell.onSwitcher.addTarget(self, action: #selector(changeSwitchAction(sender:)), for: UIControlEvents.valueChanged)
        cell.onSwitcher.isEnabled = pet.isOwner
        
        
        if let preview = safezone.preview {
            cell.safeZoneImage.image = UIImage(data: preview as Data)
        }else{
            cell.safeZoneImage.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        return cell
    }
    
    
    
    func changeSwitchAction(sender: UISwitch){
        let safezone = presenter.safeZones[sender.tag]
        presenter.setSafeZoneStatus(id: safezone.id, petId: pet.id, status: sender.isOn) { (success) in
            if !success {
                sender.isOn = !sender.isOn
            }else if success && sender.isOn {
                
                UIApplication.shared.keyWindow?.rootViewController?.popUp(title: "Done", msg: "Safe Zone Has Been Turned On")


            }else if success && !sender.isOn {
                UIApplication.shared.keyWindow?.rootViewController?.popUp(title: "Done", msg: "Safe Zone Has Been Turned On")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let myViewController = parentViewController as? PetProfileCollectionViewController {
            DispatchQueue.main.async {
                let safeZone = self.presenter.safeZones[indexPath.item]
                print(" before \(safeZone.name!)")
                myViewController.presentEditSafezoneViewController(petId: self.pet.id, isOwner: self.pet.isOwner, safeZone: safeZone)

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
