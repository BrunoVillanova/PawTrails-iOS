//
//  PetProfileTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 21/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetProfileTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, PetView {

    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var safeZonesCollectionView: UICollectionView!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var usersTableViewCell: UITableViewCell!
    @IBOutlet weak var safezonesTableViewCell: UITableViewCell!
    @IBOutlet weak var addSafeZoneTableViewCell: UITableViewCell!
    
    var pet:Pet!
    
    fileprivate let sectionNames = ["info", "users", "safe zones"]
    
    fileprivate let presenter = PetPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        if let pet = pet { load(pet) }
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20.0))

        petImageView.circle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.loadPet(with: pet.id ?? "")
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
        genderLabel.text = Gender(rawValue: Int(pet.gender))?.name
        typeLabel.text = pet.typeString
        weightLabel.text = pet.weight?.toString()
        birthdayLabel.text = pet.birthday?.toStringShow
        
        usersCollectionView.reloadData()
        

        if pet.safezones != nil && pet.safezones!.count > 0 {
            addSafeZoneTableViewCell.isHidden = true
            safezonesTableViewCell.isHidden = false
            safeZonesCollectionView.reloadData()
        }else{
            addSafeZoneTableViewCell.isHidden = false
            safezonesTableViewCell.isHidden = true
        }

        tableView.reloadData()
    }
    
    func petNotFound() {
        alert(title: "", msg: "couldn't load pet")
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
        
        let editButtonWidth = headerView.frame.width - titleWidth - margin
        
        let editButton = UIButton(frame: CGRect(x: titleWidth, y: 0.0, width: editButtonWidth, height: headerView.frame.height - margin))
        editButton.setTitle("Edit", for: .normal)
        editButton.contentHorizontalAlignment = .right
        editButton.setTitleColor(UIColor.orange(), for: .normal)
        editButton.isEnabled = true
        editButton.tag = section
        editButton.addTarget(self, action: #selector(editPressed(sender:)), for: .touchDown)
        headerView.addSubview(editButton)
        
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
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
    }
    
    // MARK: - UICollectionDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case safeZonesCollectionView: return pet.safezones?.count ?? 0
        case usersCollectionView: return pet.guests != nil ? pet.guests!.count + 1 : 1
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == safeZonesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! petProfileSafeZoneCollectionCell
            cell.elementImageView.backgroundColor = UIColor.red
            cell.titleLabel.text = "Safe Zone \(indexPath.row)"
            return cell
        }else if collectionView == usersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! petProfileUserCollectionCell
            
            cell.elementImageView.circle()
            
            if indexPath.row == 0 {
                // Owner
                cell.elementImageView.backgroundColor = UIColor.orange()
                cell.elementImageView.border(color: .orange(), width: 2.0)
                if let owner = pet.owner {
                    let imageData = owner.image ?? NSData()
                    cell.elementImageView.image = UIImage(data: imageData as Data)
                    let fullName = "\(owner.name ?? "") \(owner.surname ?? "")"
                    cell.titleLabel.text = fullName
                }else{
                    cell.elementImageView.image = nil
                    cell.titleLabel.text = "Owner"
                }
            }else{
                // Guests
                cell.elementImageView.backgroundColor = UIColor.lightGray
                cell.elementImageView.border(color: .clear, width: 2.0)
                if let guest = pet.guests?.allObjects[indexPath.row - 1] as? PetUser {
                    let imageData = guest.image ?? NSData()
                    cell.elementImageView.image = UIImage(data: imageData as Data)
                    cell.titleLabel.text = guest.name
                }else{
                    cell.elementImageView.image = nil
                    cell.titleLabel.text = "Guest"
                }
            }
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == safeZonesCollectionView {
            if let safezone = pet.safezones?.allObjects[indexPath.row] as? SafeZone {
                present(safezone)
            }else{
                //
            }
        }else if collectionView == usersCollectionView {
            if indexPath.row == 0 {
                //owner
                if let owner = pet.owner {
                    present(owner, isOwner: true)
                }else{
                    // error
                }
            }else{
                //guest
                if let guest = pet.guests?.allObjects[indexPath.row - 1] as? PetUser {
                    present(guest, isOwner: false)
                }else{
                    // error
                }
            }
        }
    }
    
    func present(_ safezone: SafeZone) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZoneViewController") as? AddEditSafeZoneViewController {
            vc.safezone = safezone
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func present(_ user: PetUser, isOwner: Bool) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetUserTableViewController") as? PetUserTableViewController {
            vc.isOwner = isOwner
            vc.petUser = user
            vc.petName = pet.name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

class petProfileSafeZoneCollectionCell: UICollectionViewCell {
    @IBOutlet weak var elementImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

class petProfileUserCollectionCell: UICollectionViewCell {
    @IBOutlet weak var elementImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
