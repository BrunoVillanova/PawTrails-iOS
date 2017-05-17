//
//  UserProfileTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 31/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController, UserProfileView, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    let presenter = UserProfilePresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.circle()
        presenter.attachView(self)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.loadUser()
        if let selectedIndexes = tableView.indexPathsForSelectedRows {
            for selectedIndex in selectedIndexes {
                tableView.deselectRow(at: selectedIndex, animated: true)
            }
        }
    }
    
    //MARC:- UserProfileView
    
    func load(user: User) {

        var fullname: String {
            let name = user.name ?? ""
            let surname = user.surname ?? ""
            return "\(name) \(surname)"
        }
        nameLabel.text = fullname
        emailLabel.text = user.email
        genderLabel.text = Gender(rawValue: user.gender)?.name
        birthdayLabel.text = user.birthday?.toStringShow
        phoneLabel.text = user.phone?.toString
        addressLabel.text = user.address?.toString
        
        if let imageData = user.image {
            profileImageView.image = UIImage(data: imageData as Data)
        }
        tableView.reloadData()
    }
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userNotSigned() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: {
                self.tabBarController?.selectedIndex = 0
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor.white
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is EditUserProfileTableViewController {
            (segue.destination as! EditUserProfileTableViewController).user = presenter.user
        }
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
