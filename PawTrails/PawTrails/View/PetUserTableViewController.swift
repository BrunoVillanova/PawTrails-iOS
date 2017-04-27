//
//  PetUserTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 25/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetUserTableViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var actionLabel: UILabel!
    
    var petName: String!
    var petUser: PetUser!
    var isOwner: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "User Profile"
        navigationItem.prompt = petName
        
        if petUser == nil {
            popAction(sender: nil)
        }else{

            nameLabel.text = petUser.name
            surnameLabel.text = petUser.surname
            
            let color: UIColor = isOwner ? .orange() : .lightGray
            let imageData = petUser.image ?? NSData()
            imageView.circle()
            imageView.border(color: color, width: 2.0)
            imageView.backgroundColor = .white
            imageView.image = UIImage(data: imageData as Data)
            imageView.border(color: color, width: 2.0)

            
            let petUserId = petUser.id ?? "-"
            let currentUserId = SharedPreferences.get(.id) ?? "§"
            
            
            if petUserId == currentUserId {
                emailLabel.text = petUser.email
                let name = petName ?? ""
                actionLabel.text = "Remove me from '\(name)'"
            }else if isOwner {
                emailLabel.text = petUser.email
                let name = petName ?? ""
                actionLabel.text = "Remove this user from '\(name)'"
            }else{
                emailCell.isHidden = true
            }
            
        }
        
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            popUp(title: "Under Construction", msg: "")
        }
        
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
