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
        navigationItem.prompt = pet.name
        
        if petUser == nil {
            popAction(sender: nil)
        }else{

            nameLabel.text = petUser.name
            surnameLabel.text = petUser.surname
            
            let imageData = petUser.image ?? Data()
            imageView.image = UIImage(data: imageData)
            imageView.setupLayout(isPetOwner: pet.isOwner(petUser))
            
            let name = pet.name ?? ""
            emailLabel.text = petUser.email
           
            currentUserId = Int(petUser.id)
            petOwnerId = pet.owner?.id ?? -2
            appUserId = Int(SharedPreferences.get(.id) ?? -3)

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
        
//        if indexPath.section == 1 {
//            
//            if currentUserId == petOwnerId && petOwnerId == appUserId {
//                // Remove Pet
//                presenter.removePet(with: pet.id)
//            }else if appUserId == petOwnerId && appUserId != currentUserId {
//                // Owner Remove that user
//                presenter.removePetUser(with: petUser.id, from: pet.id)
//            }else if appUserId == currentUserId && appUserId != petOwnerId {
//                // That user leaves pet
//                presenter.leavePet(with: pet.id)
//            }
//        }
        
    }
    
    // MARK:- PetUserView
    
    func removed() {
        
        if appUserId == petOwnerId && appUserId != currentUserId {
            if let petPage = navigationController?.viewControllers.first(where: { $0 is PetsPageViewController}) as? PetsPageViewController {
                navigationController?.popToViewController(petPage, animated: true)
            }
        }else{
            navigationController?.navigationBar.topItem?.prompt = nil
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
