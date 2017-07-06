//
//  PetUserTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 25/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetUserTableViewController: UITableViewController, PetUserView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var actionCell: UITableViewCell!
    @IBOutlet weak var actionLabel: UILabel!
    
    var pet: Pet!
    var petUser: PetUser!
    
    fileprivate let presenter = PetUserPresenter()
    
    fileprivate var currentUserId = -1
    fileprivate var petOwnerId = -2
    fileprivate var appUserId = -3

    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        navigationItem.title = "User Profile"
        
        if petUser == nil {
            popAction(sender: nil)
        }else{

            nameLabel.text = petUser.name
            surnameLabel.text = petUser.surname
            
            let imageData = petUser.image ?? Data()
            imageView.image = UIImage(data: imageData)
            imageView.setupLayout(isPetOwner: petUser.isOwner)
            
            let name = pet.name ?? ""
            emailLabel.text = petUser.email
           
            if let owner = pet.owner  {
                currentUserId = Int(petUser.id)
                petOwnerId = Int(owner.id)
                appUserId = Int(SharedPreferences.get(.id)) ?? -3
            }

            if currentUserId == petOwnerId && petOwnerId == appUserId {
                // Remove Pet
                actionLabel.text = "Remove '\(name)'"
            }else if appUserId == petOwnerId && appUserId != currentUserId {
                // Owner Remove that user
                actionLabel.text = "Remove \(petUser.name ?? "this user") from '\(name)'"
            }else if appUserId == currentUserId && appUserId != petOwnerId {
                // That user leaves pet
                emailCell.isHidden = true
                actionLabel.text = "Leave '\(name)'"
            }else{
                emailCell.isHidden = true
                actionCell.isHidden = true
                tableView.reloadData()
            }
        }
    }
    
    deinit {
        presenter.deteachView()
    }

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            DispatchQueue.main.async {
                if self.currentUserId == self.petOwnerId && self.petOwnerId == self.appUserId {
                    // Remove Pet
                    self.popUpDestructive(title: "Remove \(self.pet.name ?? "this pet")", msg: "If you proceed you will loose all the information of this pet.", cancelHandler: nil, proceedHandler: { (remove) in
                        self.presenter.removePet(with: self.pet.id)
                    })
                }else if self.appUserId == self.petOwnerId && self.appUserId != self.currentUserId {
                    // Owner Remove that user
                    self.popUpDestructive(title: "Remove \(self.petUser.name ?? "this user") from \(self.pet.name ?? "this pet")", msg: "If you proceed you will remove this user from the pet sharing list.", cancelHandler: nil, proceedHandler: { (remove) in
                        self.presenter.removePetUser(with: self.petUser.id, from: self.pet.id)
                    })
                }else if self.appUserId == self.currentUserId && self.appUserId != self.petOwnerId {
                    // That user leaves pet
                    self.popUpDestructive(title: "Leave \(self.pet.name ?? "this pet")", msg: "If you proceed you will leave this pet sharing list.", cancelHandler: nil, proceedHandler: { (remove) in
                        self.presenter.leavePet(with: self.pet.id)
                    })
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
    }
    
    // MARK:- PetUserView
    
    func removed() {
        
        if appUserId == petOwnerId && appUserId != currentUserId {
            if let profile = navigationController?.viewControllers.first(where: { $0 is PetProfileTableViewController}) as? PetProfileTableViewController {
                profile.reloadUsers()
                navigationController?.popToViewController(profile, animated: true)
            }
        }else if let petList = navigationController?.viewControllers.first(where: { $0 is PetsViewController}) as? PetsViewController {
            petList.reloadPets()
            navigationController?.popToViewController(petList, animated: true)
        }else{
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: "", msg: error.msg)
    }

    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        hideLoadingView()
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return actionCell.isHidden ? 1 : 2
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
