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
        return pet.users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! basicTableViewCell

        
        let user = pet.users?.allObjects[indexPath.row] as! PetUser

        cell.leftImageView?.circle()
        
        let fullName = "\(user.name ?? "") \(user.surname ?? "")"
        cell.titleLabel?.text = fullName
        let imageData = user.image ?? NSData()
        cell.leftImageView?.image = UIImage(data: imageData as Data)
        
        if user == pet.owner {
            cell.imageView?.backgroundColor = UIColor.orange()
            cell.imageView?.border(color: .orange(), width: 2.0)
            cell.rightDetailLabel.text = "owner"
        }else{
            cell.imageView?.backgroundColor = UIColor.lightGray
            cell.imageView?.border(color: .clear, width: 2.0)
            cell.rightDetailLabel.text = nil
        }

        return cell
    }

    // MARK: - UITableViewDelegate

     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let owner = pet.owner {
            guard let petUserId = owner.id else { return false }
            guard let currentUserId = SharedPreferences.get(.id) else { return false }
            return petUserId == currentUserId
        }
        return false
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            
//            
//            let user = pet.users?.allObjects[indexPath.row] as! PetUser
//            
//            if user == pet.owner {
//                popUp(title: "Warning", msg: "If you want to remove yourself as a user, you have to transfer the pet ownership to someone else first.")
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
                vc.petUser = pet.users?.allObjects[selected.row] as? PetUser
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


































