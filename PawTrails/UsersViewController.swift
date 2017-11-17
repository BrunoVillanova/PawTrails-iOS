//
//  UsersViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 15/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addUserBtn: UIButton!
    
    
    var users: [PetUser]?
    var pet: Pet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let petuser = pet.owner {
            let currentuser = Int(SharedPreferences.get(.id)) ?? -3
            if petuser.id != currentuser {
                self.addUserBtn.isHidden = true
            } else {
                self.addUserBtn.isHidden = false
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let users = users {
            return users.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UsersTableViewCell, let user = self.users{
            let userAtIndex = user[indexPath.row]
            cell.nameLbl.text = userAtIndex.name
            cell.emailLbl.text = userAtIndex.email
            cell.profileImage.circle()
            if let url = userAtIndex.imageURL {
                cell.profileImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""), options: [.progressiveDownload], completed: nil)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nothing", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let users = self.users {
            let user = users[indexPath.row]
            present(user, isOwner: user.isOwner)
        }
    }
    
    
    func present(_ user: PetUser, isOwner: Bool) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PetUserTableViewController") as? PetUserTableViewController, let userPet = self.pet {
            vc.petUser = user
            vc.pet = userPet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func addUserbtnPressed(_ sender: Any) {
        presentAddUser()
    }
    
    
    
    
    func presentAddUser() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddPetUserViewController") as? AddPetUserViewController, let userPet = self.pet {
            vc.pet = userPet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


class UsersTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
}
