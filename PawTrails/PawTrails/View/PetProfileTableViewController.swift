//
//  PetProfileTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 21/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit

class PetProfileTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, PetView {
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var neuteredLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var safeZonesCollectionView: UICollectionView!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var usersTableViewCell: UITableViewCell!
    @IBOutlet weak var safezonesTableViewCell: UITableViewCell!
    @IBOutlet weak var addSafeZoneTableViewCell: UITableViewCell!
    @IBOutlet weak var removeLeaveLabel: UILabel!
    
    var pet:Pet!
    
    fileprivate let sectionNames = ["info", "users", "safe zones", "actions"]
    
    fileprivate let presenter = PetPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        usersCollectionView.reloadData()
        if let pet = pet {
            load(pet)
            presenter.loadPet(with: pet.id)
            presenter.loadPetUsers(for: pet.id)
            presenter.loadSafeZone(for: pet.id)
            removeLeaveLabel.text = pet.isOwner ? "Remove Pet" : "Leave Pet"
        }
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20.0))
        }
    
    override func viewWillAppear(_ animated: Bool) {
        //        presenter.loadPet(with: pet.id ?? "")
        presenter.getPet(with: pet.id)
    }
    
    func reloadUsers() {
        presenter.loadPetUsers(for: pet.id)
    }
    
    //MARK: - PetView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func load(_ pet: Pet) {
        
        if let imageData = pet.image {
            petImageView.image = UIImage(data: imageData as Data)
        }
        
        breedLabel.text = pet.breeds
        genderLabel.text = Gender(rawValue: pet.gender)?.name
        typeLabel.text = pet.typeString
        weightLabel.text = pet.weight.toWeightString
        birthdayLabel.text = pet.birthday?.toStringShow
        neuteredLabel.text = pet.neutered ? "Yes" : "No"
        
        usersCollectionView.reloadAnimated()
        
        if presenter.safezones.count > 0 {
            addSafeZoneTableViewCell.isHidden = true
            safezonesTableViewCell.isHidden = false

            let safezonesGroup = DispatchGroup()
            
            for safezone in self.presenter.safezones {
                safezonesGroup.enter()
                self.buildMap(for: safezone, handler: {
                    safezonesGroup.leave()
                })
            }
            
            safezonesGroup.notify(queue: .main, execute: {
                self.safeZonesCollectionView.reloadData()
            })

        }else if pet.isOwner {
            addSafeZoneTableViewCell.isHidden = false
            safezonesTableViewCell.isHidden = true
        }else {
            addSafeZoneTableViewCell.isHidden = true
            safezonesTableViewCell.isHidden = true
        }
        removeLeaveLabel.text = pet.isOwner ? "Remove Pet" : "Leave Pet"
        tableView.reloadData()
    }
    
    func petNotFound() {
        alert(title: "", msg: "couldn't load pet")
    }
    
    func petRemoved() {
        popAction(sender: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 23))
        
        let titleWidth = headerView.frame.width * 0.6
        let margin:CGFloat = 5.0
        
        let title = UILabel(frame: CGRect(x: margin, y: 0.0, width: titleWidth, height: headerView.frame.height - margin))
        title.text = sectionNames[section].uppercased()
        title.font = UIFont.preferredFont(forTextStyle: .body)
        title.textColor = UIColor.darkGray
        headerView.addSubview(title)
        
        if pet.isOwner && section != 3 {
            
            let editButtonWidth = headerView.frame.width - titleWidth - margin
            
            let editButton = UIButton(frame: CGRect(x: titleWidth, y: 0.0, width: editButtonWidth, height: headerView.frame.height - margin))
            editButton.setTitle("Edit", for: .normal)
            editButton.contentHorizontalAlignment = .right
            editButton.setTitleColor(UIColor.orange(), for: .normal)
            editButton.isEnabled = true
            editButton.tag = section
            editButton.addTarget(self, action: #selector(editPressed(sender:)), for: .touchDown)
            headerView.addSubview(editButton)
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func editPressed(sender: UIButton){
        
        switch sender.tag {
        case 0:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
                vc.pet = pet
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetUsersViewController") as? PetUsersViewController {
                vc.pet = pet
                navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetSafeZonesViewController") as? PetSafeZonesViewController {
                vc.pet = pet
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 && ((indexPath.row == 0 && safezonesTableViewCell.isHidden) || (indexPath.row == 1 && addSafeZoneTableViewCell.isHidden)){
            return 0
        }else if indexPath.section == 0 && indexPath.row == 1 && breedLabel.text != nil && breedLabel.text != "" {

            let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: breedLabel.frame.width, height: CGFloat(MAXFLOAT)))
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.text = breedLabel.text
            label.sizeToFit()
            return 36.0 + label.frame.height
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 && indexPath.row == 1 {
            // Leave/Remove Pet
            if pet.isOwner {
                popUpDestructive(title: "Remove \(pet.name ?? "this pet")", msg: "If you proceed you will loose all the information of this pet.", cancelHandler: nil, proceedHandler: { (remove) in
                    self.presenter.removePet(with: self.pet.id)
                })
            }else{
                popUpDestructive(title: "Leave \(pet.name ?? "this pet")", msg: "If you proceed you will leave this pet sharing list.", cancelHandler: nil, proceedHandler: { (remove) in
                    self.presenter.leavePet(with: self.pet.id)
                })
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 1 && addSafeZoneTableViewCell.isHidden == false {
            present(nil)
        }
    }
    
    // MARK: - UICollectionDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case safeZonesCollectionView: return presenter.safezones.count
        case usersCollectionView: return presenter.users.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == safeZonesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! petProfileSafeZoneCollectionCell
            
            let safezone = presenter.safezones[indexPath.row]
            cell.elementImageView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            cell.titleLabel.text = safezone.name
            cell.activeSwitch.isOn = safezone.active
            cell.activeSwitch.tag = indexPath.row
            cell.activeSwitch.addTarget(self, action: #selector(changeSwitchAction(sender:)), for: UIControlEvents.valueChanged)
            
            if let preview = safezone.preview {
                cell.elementImageView.image = UIImage(data: preview as Data)
            }else{
                cell.elementImageView.backgroundColor = UIColor.orange().withAlphaComponent(0.8)
            }
            return cell
        }else if collectionView == usersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! petProfileUserCollectionCell
            
            let user = presenter.users[indexPath.row]
            
            let imageData = user.image ?? Data()
            cell.elementImageView.image = UIImage(data: imageData)
            cell.elementImageView.setupLayout(isPetOwner: user.isOwner)
            
            let fullName = "\(user.name ?? "") \(user.surname ?? "")"
            cell.titleLabel.text = fullName
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func buildMap(for safezone: SafeZone, handler: @escaping (()->())) {
        if safezone.preview == nil, let center = safezone.point1?.coordinates, let topCenter = safezone.point2?.coordinates, let shape = Shape(rawValue: safezone.shape) {
            
            MKMapView.getSnapShot(with: center, topCenter: topCenter, shape: shape, into: view, handler: { (image) in
                if let image = image, let data = UIImagePNGRepresentation(image) {
                    self.presenter.set(safezone: safezone, imageData: data)
                    handler()
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == safeZonesCollectionView {
            
            present(presenter.safezones[indexPath.row])
            
        }else if collectionView == usersCollectionView {
            let user = presenter.users[indexPath.row]
            present(user, isOwner: pet.isOwner(user))
        }
    }
    
    func changeSwitchAction(sender: UISwitch){
        let safezone = presenter.safezones[sender.tag]
        presenter.setSafeZoneStatus(id: safezone.id, petId: pet.id, status: sender.isOn)
    }
    
    func present(_ safezone: SafeZone?) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZoneViewController") as? AddEditSafeZoneViewController {
            vc.safezone = safezone
            vc.petId = pet.id
            vc.isOwner = pet.isOwner
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func present(_ user: PetUser, isOwner: Bool) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetUserTableViewController") as? PetUserTableViewController {
            vc.petUser = user
            vc.pet = pet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeDevice" {
            if let navigationController = segue.destination as? UINavigationController {
                if let childVC = navigationController.topViewController as? AddPetDeviceTableViewController {
                    childVC.petId = pet.id
                }
            }
        }
    }
    
}

class petProfileSafeZoneCollectionCell: UICollectionViewCell {
    @IBOutlet weak var elementImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
}

class petProfileUserCollectionCell: UICollectionViewCell {
    @IBOutlet weak var elementImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
