//
//  PetInfromationViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SDWebImage

class PetInfromationViewController: UIViewController, IndicatorInfoProvider, PetView {
    var pet: Pet!
    fileprivate let presenter = PetPresenter()
    
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 1000
        
        usersCollectionView.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        let leftItemBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(leftBarButtonTapped))
        self.navigationItem.rightBarButtonItem = leftItemBarButton
        
        usersCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        
        
        usersCollectionView.delegate = self
        usersCollectionView.dataSource = self
        
        presenter.attachView(self, pet:pet)
        if let pet = pet {
            reloadPetInfo()
            reloadUsers()
            load(pet)
            
        }
        
        let nib = UINib(nibName: "SharedUsersTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "nib")
        
        let notificationIdentifier: String = "petAdded"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPetInfo), name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
        
    }
    
    deinit {
        presenter.deteachView()
    }
    
    func leftBarButtonTapped() {
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Profile")
    }
    
    
    func tap(sender: UITapGestureRecognizer){
        self.present(presenter.users)
        
    }
    
    
    func reloadUsers(onlyDB: Bool = false) {
        if onlyDB {
            presenter.getPet(with: pet.id)
            self.tableView.reloadData()
            //reload users?
        }else{
            presenter.loadPetUsers(for: pet.id)
            self.usersCollectionView.reloadData()
            
        }
    }
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func load(_ pet: Pet) {
        self.pet = pet
        self.tableView.reloadData()
    }
    func reloadPetInfo() {
        presenter.loadPet(with: pet.id)
    }
    
    func loadUsers() {
        pet.users = presenter.users
        tableView.reloadData()
    }
    
    func loadSafeZones() {
        // dp nothing
    }
    
    func petNotFound() {
        alert(title: "", msg: "couldn't load pet")
        
    }
    
    func petRemoved() {
        if let petList = navigationController?.viewControllers.first(where: { $0 is PetListViewController}) as? PetListViewController {
            petList.reloadPets()
            navigationController?.popToViewController(petList, animated: true)
        }else{
            popAction(sender: nil)
        }
    }
    
    func removed() {
        self.reloadUsers()
    }
    
    
}

extension PetInfromationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileInfoCell
        
        if let pet = self.pet{
            cell.petName.text = pet.name
            cell.breedLbl.text = pet.breedsString
            cell.genderLbl.text = pet.gender?.name
            cell.weightLbl.text = pet.weightString
            cell.typeLbl.text = pet.typeString
            cell.birthDayLbl.text = pet.birthday?.toStringShow
            cell.sizeLbl.text = pet.size?.description
            cell.profileImage.imageUrl = pet.imageURL
        }
        
        return cell
    }
    
    func present(_ users: [PetUser]) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as? UsersViewController {
            vc.users = users
            vc.pet = pet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PetInfromationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if presenter.users.count > 0 {
            return presenter.users.count
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = usersCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UsersCell
        cell.profileImage.border(color: UIColor.primary, width: 0.7)
        
        if presenter.users.count > indexPath.row {
            let user = presenter.users[indexPath.row]
            if let url = user.imageURL {
                cell.profileImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "PetPlaceholderImage"), options: [.progressiveDownload], completed: nil)
            }
        } else {
            cell.profileImage.image = #imageLiteral(resourceName: "AddCircularBigIcon")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.present(presenter.users)
    }
}

class ProfileInfoCell: UITableViewCell {
    @IBOutlet weak var profileImage: PTBalloonImageView!
    @IBOutlet weak var birthDayLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var breedLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var sizeLbl: UILabel!
    
}

class UsersCell: UICollectionViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        self.profileImage.circle()
        
    }
    
    override func prepareForReuse() {
        self.profileImage = nil
    }
}

