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
    @IBOutlet weak var removeLeaveButton: UIButton!
    @IBOutlet weak var changeTableViewCell: UITableViewCell!
    
    var pet:Pet!
    var fromMap: Bool = false
    
    enum petProfileSection: Int {
        case info = 0, activity, users, safezones, actions
        
        var name: String {
            switch self {
            case .info: return "info"
            case .activity: return "activity"
            case .users: return "users"
            case .safezones: return "safe zones"
            case .actions: return "actions"
            }
        }
        
        var actionName: String? {
            switch self {
            case .info: return "Edit"
            case .activity: return "View"
            case .users, .safezones: return "Add"
            default: return nil
            }
        }
    }
    
    fileprivate let presenter = PetPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(self, pet:pet)

        
        if let pet = pet {
            load(pet)
            reloadPetInfo()
            reloadUsers()
            reloadSafeZones()
            removeLeaveButton.setTitle(pet.isOwner ? "Remove Pet" : "Leave Pet", for: .normal)
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
            Reporter.debugPrint(file: "\(#file)", function: "\(#function)", "Released Geocode \(type) - \(name)")
            if type == .pet {
                self.load(locationAndTime: name)
            }else if type == .safezone {
                self.presenter.getPet(with: self.pet.id)
            }
        })
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopPetGPSUpdates(of: pet.id)
        presenter.stopPetsGeocodeUpdates()
        self.tabBarController?.tabBar.isHidden = false
    }

    func reloadPetInfo() {
        presenter.loadPet(with: pet.id)
    }
    
    func reloadSafeZones() {
        presenter.loadSafeZones(for: pet.id)
    }
    
    func reloadUsers(onlyDB: Bool = false) {
        if onlyDB {
            presenter.getPet(with: pet.id)
            //reload users?
        }else{
            presenter.loadPetUsers(for: pet.id)
        }
    }
    
    //MARK: - PetView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func load(_ pet: Pet) {
        self.pet = pet
        navigationItem.title = pet.name
        if let imageData = pet.image {
            petImageView.image = UIImage(data: imageData as Data)
        }
        
        breedLabel.text = pet.breedsString
        genderLabel.text = pet.gender?.name
        typeLabel.text = pet.typeString
        weightLabel.text = pet.weightString
        birthdayLabel.text = pet.birthday?.toStringShow
        neuteredLabel.text = pet.neutered ? "Yes" : "No"

        removeLeaveButton.setTitle(pet.isOwner ? "Remove Pet" : "Leave Pet", for: .normal)
        changeTableViewCell.isHidden = !pet.isOwner
        
        if let data = SocketIOManager.instance.getGPSData(for: pet.id) {
            self.load(data: data)
        }
        tableView.reloadData()
        self.usersCollectionView.reloadData()
        self.safeZonesCollectionView.reloadData()

    }
    
    func loadUsers() {
        pet.users = presenter.users
        usersCollectionView.reloadAnimated()
        tableView.reloadData()
    }
    
    func loadSafeZones() {
        pet.safezones = presenter.safezones
        
        if self.presenter.safezones.count == 0 { return }
        
        let safezonesGroup = DispatchGroup()
        
        for safezone in self.presenter.safezones {
            // Address
            if safezone.address == nil {
//                Reporter.debug("address", safezone.id)
                
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
    
    func load(data: GPSData){
        self.signalImageView.tintColor = UIColor.primary
        self.signalLabel.text = data.signalString
        self.batteryImageView.tintColor = UIColor.primary
        self.batteryLabel.text = data.batteryString
        if data.status != .idle {
            self.signalLabel.alpha = 0.5
            self.signalImageView.alpha = 0.5
            self.batteryLabel.alpha = 0.5
            self.batteryImageView.alpha = 0.5
            self.locationLabel.textColor = UIColor.darkGray
        }else{
            self.locationLabel.textColor = UIColor.lightGray
        }
        if data.locationAndTime != "" {
            load(locationAndTime: data.locationAndTime)
        }else{
            load(locationAndTime: Message.instance.get(data.status))
        }
    }
    
    func load(locationAndTime: String){
        self.locationLabel.text = locationAndTime
    }

    
    func petNotFound() {
        alert(title: "", msg: "couldn't load pet")
    }
    
    func petRemoved() {
        if let petList = navigationController?.viewControllers.first(where: { $0 is PetsViewController}) as? PetsViewController {
            petList.reloadPets()
            navigationController?.popToViewController(petList, animated: true)
        }else{
            popAction(sender: nil)
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let petProfileSection = petProfileSection(rawValue: section) {
            
            if petProfileSection == .activity { return nil }
            
            let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 30.0))
            
            let titleWidth = headerView.frame.width * 0.6
            let margin:CGFloat = 5.0
            
            let title = UILabel(frame: CGRect(x: margin, y: 0.0, width: titleWidth, height: headerView.frame.height - margin))
            title.text = petProfileSection.name.uppercased()
            title.font = UIFont.preferredFont(forTextStyle: .headline)
            title.textColor = UIColor.darkGray
            headerView.addSubview(title)
            
            if pet.isOwner, let actionName = petProfileSection.actionName {
                
                let editButtonWidth = headerView.frame.width - titleWidth - margin
                
                let editButton = UIButton(frame: CGRect(x: titleWidth, y: 0.0, width: editButtonWidth, height: headerView.frame.height - margin))
                editButton.setTitle(actionName, for: .normal)
                editButton.setTitleColor(UIColor.primary, for: .normal)
                editButton.contentHorizontalAlignment = .right
                editButton.isEnabled = true
                editButton.tag = section
                editButton.addTarget(self, action: #selector(editPressed(sender:)), for: .touchDown)
                headerView.addSubview(editButton)
            }
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    func editPressed(sender: UIButton){
        
        if let petProfileSection = petProfileSection(rawValue: sender.tag) {
            switch petProfileSection {
            case .info:
                if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
                    vc.pet = pet
                    navigationController?.pushViewController(vc, animated: true)
                }
            case .activity:
                if let vc = storyboard?.instantiateViewController(withIdentifier: "PetActivityViewController") as? PetActivityViewController {
                    vc.pet = pet
                    navigationController?.pushViewController(vc, animated: true)
                }
            case .users:
                if let vc = storyboard?.instantiateViewController(withIdentifier: "AddPetUserViewController") as? AddPetUserViewController {
                    vc.pet = pet
                    navigationController?.pushViewController(vc, animated: true)
                }
            case .safezones:
                if let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditSafeZoneViewController") as? AddEditSafeZoneViewController {
                    vc.petId = pet.id
                    vc.isOwner = pet.isOwner
                    navigationController?.pushViewController(vc, animated: true)
                }
            default:
                break
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.section == 1) || (indexPath.section == 2 && self.presenter.users.count == 0) || (indexPath.section == 3 && self.presenter.safezones.count == 0) || (indexPath.section == 4 && indexPath.row == 0 && self.pet.isOwner == false) {
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
            DispatchQueue.main.async {
                // Leave/Remove Pet
                if self.pet.isOwner {
                    self.popUpDestructive(title: "Remove \(self.pet.name ?? "this pet")", msg: "If you proceed you will loose all the information of this pet.", cancelHandler: nil, proceedHandler: { (remove) in
                        self.presenter.removePet(with: self.pet.id)
                    })
                }else{
                    self.popUpDestructive(title: "Leave \(self.pet.name ?? "this pet")", msg: "If you proceed you will leave this pet sharing list.", cancelHandler: nil, proceedHandler: { (remove) in
                        self.presenter.leavePet(with: self.pet.id)
                    })
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
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
                sender.isOn = !sender.isOn
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
