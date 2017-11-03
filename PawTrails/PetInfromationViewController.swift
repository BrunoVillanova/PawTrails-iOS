//
//  PetInfromationViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PetInfromationViewController: UIViewController, IndicatorInfoProvider, PetView {
    var pet: Pet!
    fileprivate let presenter = PetPresenter()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 1000

        presenter.attachView(self, pet:pet)
        if let pet = pet {
            reloadPetInfo()
            reloadUsers()
            load(pet)

        }
        
        let nib = UINib(nibName: "SharedUsersTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "nib")
        
    }
    deinit {
        presenter.deteachView()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Profile")
    }
    
    
    func reloadUsers(onlyDB: Bool = false) {
        if onlyDB {
            presenter.getPet(with: pet.id)
            self.tableView.reloadData()
            //reload users?
        }else{
            presenter.loadPetUsers(for: pet.id)
            self.tableView.reloadData()

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
        if let petList = navigationController?.viewControllers.first(where: { $0 is PetsViewController}) as? PetsViewController {
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return presenter.users.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let user = presenter.users[indexPath.row]
            self.present(user, isOwner: user.isOwner)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileInfoCell

        if indexPath.section == 0 {
            cell.isUserInteractionEnabled = false

            if let pet = self.pet{
                cell.petName.text = pet.name
                cell.breedLbl.text = pet.breedsString
                cell.genderLbl.text = pet.gender?.name
                cell.weightLbl.text = pet.weightString
                cell.typeLbl.text = pet.typeString
                cell.birthDayLbl.text = pet.birthday?.toStringShow
                if let image = pet.image {
                    cell.profileImage.image = UIImage(data: image)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nib", for: indexPath) as! SharedUsersTableViewCell
            let user = presenter.users[indexPath.row]
            let imageData = user.image ?? Data()
            cell.userImage.image = UIImage(data: imageData)
            let fullName = "\(user.name ?? "") \(user.surname ?? "")"
            cell.nameLbl.text = fullName
            cell.emailLbl.text = user.email
//            cell.removebtn.addTarget(self, action: #selector(removeBtnPressed), for: .touchUpInside)
            return cell

        }

    }
    
    
    
    func present(_ user: PetUser, isOwner: Bool) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetUserTableViewController") as? PetUserTableViewController {
            vc.petUser = user
            vc.pet = pet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
//    func removeBtnPressed(sender: UIButton?) {
//
//            let selectedUser = presenter.users[(sender?.tag)!]
//            let owner = pet.owner
//            let appuser = Int(SharedPreferences.get(.id))
//
//
//            if appuser == owner?.id && appuser != selectedUser.id {
//                // Owner Remove that user
//                self.popUpDestructive(title: "Remove \(selectedUser.name ?? "this user") from \(pet.name ?? "this pet")", msg: "If you proceed you will remove this user from the pet sharing list.", cancelHandler: nil, proceedHandler: { (remove) in
//                    self.presenter.removePetUser(with: selectedUser.id, from: self.pet.id)
//                })
//            } else if appuser == owner?.id && appuser == selectedUser.id {
//
//
//        }
//
//    }

}


class ProfileInfoCell: UITableViewCell {
    @IBOutlet weak var profileImage: UiimageViewWithMask!
    @IBOutlet weak var birthDayLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var breedLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var petName: UILabel!
    
}
