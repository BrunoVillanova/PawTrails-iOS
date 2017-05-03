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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        navigationItem.title = "User Profile"
        navigationItem.prompt = pet.name
        
        if petUser == nil {
            popAction(sender: nil)
        }else{

            nameLabel.text = petUser.name
            surnameLabel.text = petUser.surname
            

            
            let color: UIColor = pet.isOwner(petUser) ? .orange() : .lightGray
            let imageData = petUser.image ?? NSData()
            imageView.circle()
            imageView.border(color: color, width: 2.0)
            imageView.backgroundColor = .white
            imageView.image = UIImage(data: imageData as Data)
            imageView.border(color: color, width: 2.0)
            
            let name = pet.name ?? ""
            emailLabel.text = petUser.email
           
            let currentUserId = petUser.id ?? "="
            let petOwnerId = pet.owner?.id ?? "*"
            let appUserId = SharedPreferences.get(.id) ?? "§"

            if currentUserId == petOwnerId && petOwnerId == appUserId {
                // Remove Pet
                actionLabel.text = "Remove '\(name)'"
            }else if appUserId == petOwnerId && appUserId != currentUserId {
                // Owner Remove that user
                actionLabel.text = "Remove \(petUser.name ?? "this user") from '\(name)'"
            }else if appUserId == currentUserId && appUserId != petOwnerId {
                // That user leaves pet
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
        
        if indexPath.section == 1, let petId = pet.id, let userId = petUser.id {
            
            let currentUserId = petUser.id ?? "="
            let petOwnerId = pet.owner?.id ?? "*"
            let appUserId = SharedPreferences.get(.id) ?? "§"
            
            if currentUserId == petOwnerId && petOwnerId == appUserId {
                // Remove Pet
                presenter.removePet(with: petId)
            }else if appUserId == petOwnerId && appUserId != currentUserId {
                // Owner Remove that user
                presenter.removePetUser(with: userId, from: petId)
            }else if appUserId == currentUserId && appUserId != petOwnerId {
                // That user leaves pet
                presenter.leavePet(with: petId)
            }
        }
        
    }
    
    // MARK:- PetUserView
    
    func removed() {
        let currentUserId = petUser.id ?? "="
        let petOwnerId = pet.owner?.id ?? "*"
        let appUserId = SharedPreferences.get(.id) ?? "§"
        
        if currentUserId == petOwnerId && petOwnerId == appUserId {
            navigationController?.navigationBar.topItem?.prompt = nil
            navigationController?.popToRootViewController(animated: true)
        }else{
            if let vc = self.navigationController?.viewControllers.first(where: { $0 is PetProfileTableViewController }) {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: "", msg: error.msg)
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
