//
//  PetUsersViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 19/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pet:Pet!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Users Edit"
        navigationItem.prompt = pet.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PetUsersViewController.addUser))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView()
    }
    
    func addUser() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddPetUserViewController") as? AddPetUserViewController {
            vc.pet = pet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pet.sharedUsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! basicTableViewCell

        
        let user = pet.sharedUsers![indexPath.row]

        let fullName = "\(user.name ?? "") \(user.surname ?? "")"
        cell.titleLabel?.text = fullName
        
        let imageData = user.image ?? Data()
        cell.leftImageView?.image = UIImage(data: imageData)
        cell.leftImageView?.setupLayout(isPetOwner: user == pet.owner)

        cell.rightDetailLabel.text = user == pet.owner ? "owner" : "guest"

        return cell
    }

//    // MARK: - UITableViewDelegate
//
//     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if let owner = pet.owner {
//            guard let petUserId = owner.id else { return false }
//            guard let currentUserId = SharedPreferences.get(.id) else { return false }
//            return petUserId == currentUserId
//        }
//        return false
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            
//            
//            let user = pet.sharedUsers![indexPath.row]
//            
//            if user == pet.owner {
//                popUpDestructive(title: "Warning", msg: "As the owner, if you remove yourself all the information of the pet will be removed too", cancelHandler: { (cancel) in
//                    tableView.reloadRows(at: [indexPath], with: .none)
//                }, proceedHandler: { (remove) in
//                    // remove user
//                    //                        tableView.deleteRows(at: [indexPath], with: .fade)
//                })
//            }else{
//                
//                popUpDestructive(title: "Warning", msg: "Are you sure you want to remove \(user.name ?? "this user") from \(pet.name ?? "this pet") users list.", cancelHandler: { (cancel) in
//                    tableView.reloadRows(at: [indexPath], with: .none)
//                }, proceedHandler: { (remove) in
//                    // remove user
//                    //                        tableView.deleteRows(at: [indexPath], with: .fade)
//                })
//            }
//        }
//    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PetUserTableViewController {
            
            if let selected = tableView.indexPathForSelectedRow {
                
                let vc = segue.destination as! PetUserTableViewController
                vc.pet = pet
                vc.petUser = pet.sharedUsers?[selected.row]
                tableView.deselectRow(at: selected, animated: true)
            }
            
        }
        
    }
}

class basicTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightDetailLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
}


































