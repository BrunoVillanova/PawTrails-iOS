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
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var batteryImageView: UIImageView!
    @IBOutlet weak var signalLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
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
    @IBOutlet weak var removeLeaveLabel: UILabel!
    
    var pet:Pet!
    var fromMap: Bool = false
    
    fileprivate let sectionNames = ["info", "activity", "users", "safe zones", "actions"]
    
    fileprivate let presenter = PetPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(self, pet:pet)

        petImageView.circle()
        signalImageView.circle()
        batteryImageView.circle()
        
        if let pet = pet {
            load(pet)
            reloadPetInfo()
            reloadUsers()
            reloadSafeZones()
            removeLeaveLabel.text = pet.isOwner ? "Remove Pet" : "Leave Pet"
         }
        
        if fromMap {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(dismissAction(sender: )))
        }
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20.0))
    }
    
    deinit {
        presenter.deteachView()
    }
        
    override func viewWillAppear(_ animated: Bool) {

        presenter.startPetsGPSUpdates(for: pet.id) { (data) in
            self.load(data: data)
        }
        presenter.startPetsGeocodeUpdates(for: pet.id, { (type,name) in
            if type == .pet {
                self.load(locationAndTime: name)
            }else if type == .safezone {
                self.safeZonesCollectionView.reloadData()
            }
        })
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetGPSUpdates()
        presenter.stopPetsGeocodeUpdates()
        self.tabBarController?.tabBar.isHidden = false
    }

    func reloadPetInfo() {
        presenter.loadPet(with: pet.id)
    }
    
    func reloadSafeZones() {
        presenter.loadSafeZones(for: pet.id)
    }
    
    func reloadUsers() {
        presenter.loadPetUsers(for: pet.id)
    }
    
    //MARK: - PetView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func load(_ pet: Pet) {
        navigationItem.title = pet.name
        if let imageData = pet.image {
            petImageView.image = UIImage(data: imageData as Data)
        }
        
        breedLabel.text = pet.breeds
        genderLabel.text = Gender(rawValue: pet.gender)?.name
        typeLabel.text = pet.typeString
        weightLabel.text = pet.weight.toWeightString
        birthdayLabel.text = pet.birthday?.toStringShow
        neuteredLabel.text = pet.neutered ? "Yes" : "No"

        removeLeaveLabel.text = pet.isOwner ? "Remove Pet" : "Leave Pet"
        
        if let data = SocketIOManager.Instance.getGPSData(for: pet.id) {
            DispatchQueue.main.async {
                self.load(data: data)
                self.load(locationAndTime: data.locationAndTime)
            }
        }
        
        tableView.reloadData()
    }
    
    func loadUsers() {
        usersCollectionView.reloadAnimated()
        tableView.reloadData()
    }
    
    func loadSafeZones() {
        safezonesTableViewCell.isHidden = presenter.safezones.count == 0
        
        let safezonesGroup = DispatchGroup()
        
        for safezone in self.presenter.safezones {
            // Address
            if safezone.address == nil {
                debugPrint("address", safezone.id)
                
                guard let center = safezone.point1 else {
                    debugPrint("No center point found!")
                    break
                }
                GeocoderManager.Intance.reverse(type: .safezone, with: center, for: safezone.id)
            }
            // Map
            if safezone.preview == nil {
                guard let center = safezone.point1?.coordinates else {
                    debugPrint("No center point found!")
                    continue
                }
                guard let topCenter = safezone.point2?.coordinates else {
                    debugPrint("No topcenter point found!")
                    continue
                }
                guard let shape = Shape(rawValue: safezone.shape) else {
                    debugPrint("No shape found!")
                    continue
                }
                safezonesGroup.enter()
                debugPrint("map", safezone.id)
                self.buildMap(center: center, topCenter: topCenter, shape: shape, handler: { (image) in
                    if let image = image, let data = UIImagePNGRepresentation(image) {
                        self.presenter.set(safezone: safezone, imageData: data)
                    }
                    safezonesGroup.leave()
                })
            }
        }
        
        safezonesGroup.notify(queue: .main, execute: {
            self.safeZonesCollectionView.reloadData()
            self.tableView.reloadData()
        })
    }
    
    func load(data: GPSData){
        self.signalImageView.backgroundColor = UIColor.primaryColor()
        self.signalLabel.text = data.signalString
        self.batteryImageView.backgroundColor = UIColor.primaryColor()
        self.batteryLabel.text = data.batteryString
    }
    
    func load(locationAndTime: String){
        self.locationLabel.text = locationAndTime
    }
    
    func petNotFound() {
        alert(title: "", msg: "couldn't load pet")
    }
    
    func petRemoved() {
        popAction(sender: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 30.0))
        
        let titleWidth = headerView.frame.width * 0.6
        let margin:CGFloat = 5.0
        
        let title = UILabel(frame: CGRect(x: margin, y: 0.0, width: titleWidth, height: headerView.frame.height - margin))
        title.text = sectionNames[section].localizedUppercase
        title.font = UIFont.preferredFont(forTextStyle: .headline)
        title.textColor = UIColor.darkGray
        headerView.addSubview(title)
        
        if pet.isOwner && section != 4 {
            
            let editButtonWidth = headerView.frame.width - titleWidth - margin
            
            let editButton = UIButton(frame: CGRect(x: titleWidth, y: 0.0, width: editButtonWidth, height: headerView.frame.height - margin))
            var title = "Add"
            if section == 0 { title = "Edit" }
            else if section == 1 { title = "View" }
            editButton.setTitle(title, for: .normal)
            editButton.setTitleColor(UIColor.primaryColor(), for: .normal)
            editButton.contentHorizontalAlignment = .right
            editButton.isEnabled = true
            editButton.tag = section
            editButton.addTarget(self, action: #selector(editPressed(sender:)), for: .touchDown)
            headerView.addSubview(editButton)
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    func editPressed(sender: UIButton){
        
        switch sender.tag {
        case 0:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
                vc.pet = pet
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PetActivityViewController") as? PetActivityViewController {
                vc.pet = pet
                navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddPetUserViewController") as? AddPetUserViewController {
                vc.pet = pet
                navigationController?.pushViewController(vc, animated: true)
            }
        case 3:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZoneViewController") as? AddEditSafeZoneViewController {
                vc.petId = pet.id
                vc.isOwner = pet.isOwner
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 && ((indexPath.row == 0 && safezonesTableViewCell.isHidden) || (indexPath.row == 1 && safezonesTableViewCell.isHidden)){
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

        if indexPath.section == 4 && indexPath.row == 1 {
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
            cell.round()    
            let safezone = presenter.safezones[indexPath.row]
            cell.elementImageView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            cell.titleLabel.text = safezone.name
            cell.subtitleLabel.text = safezone.address
            cell.activeSwitch.isOn = safezone.active
            cell.activeSwitch.tag = indexPath.row
            cell.activeSwitch.addTarget(self, action: #selector(changeSwitchAction(sender:)), for: UIControlEvents.valueChanged)
            cell.activeSwitch.isEnabled = pet.isOwner
            
            if let preview = safezone.preview {
                cell.elementImageView.image = UIImage(data: preview as Data)
            }else{
                cell.elementImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == safeZonesCollectionView {
            
            present(presenter.safezones[indexPath.row])
            
        }else if collectionView == usersCollectionView {
            let user = presenter.users[indexPath.row]
            present(user, isOwner: user.isOwner)
        }
    }
    
    func changeSwitchAction(sender: UISwitch){
        let safezone = presenter.safezones[sender.tag]
        presenter.setSafeZoneStatus(id: safezone.id, petId: pet.id, status: sender.isOn) { (success) in
            if !success {
                DispatchQueue.main.async {
                    sender.isOn = !sender.isOn
                }
            }else if success && sender.isOn {
                self.popUp(title: "Hey", msg: "Turned On")
            }else if success && !sender.isOn {
                self.popUp(title: "Hey", msg: "Turned Off")
            }
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeDevice" {
            if let navigationController = segue.destination as? UINavigationController {
                if let childVC = navigationController.topViewController as? AddPetDeviceTableViewController {
                    childVC.petId = pet.id
                }
            }
        }
    }
    
    
    
    var lastContentOffsetAtY : CGFloat = 0.0
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffsetAtY = scrollView.contentOffset.y
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tabBarController?.tabBar.isHidden = lastContentOffsetAtY < scrollView.contentOffset.y
    }
}

class petProfileSafeZoneCollectionCell: UICollectionViewCell {
    @IBOutlet weak var elementImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
}

class petProfileUserCollectionCell: UICollectionViewCell {
    @IBOutlet weak var elementImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
