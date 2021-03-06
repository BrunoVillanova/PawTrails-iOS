//
//  UserProfileTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 31/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: PTBalloonImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    let presenter = UserProfilePresenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        configureNavigationBar()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.loadUser()
        self.hideNotification()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EditUserProfileTableViewController {
            (segue.destination as! EditUserProfileTableViewController).user = presenter.user
        } else if segue.destination is SettingsTableViewController {
            (segue.destination as! SettingsTableViewController).user = presenter.user
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            
            let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: emailLabel.frame.width, height: CGFloat(MAXFLOAT)))
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.text = emailLabel.text
            label.sizeToFit()
            return 36.0 + label.frame.height
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    fileprivate func configureNavigationBar() {
        
        if let navigationController = self.navigationController as? PTNavigationViewController {
            navigationController.showNavigationBarDropShadow = true
        }
    }
}


extension UserProfileTableViewController: UserProfileView {
    
    func load(user: User) {
        
        var fullname: String {
            let name = user.name ?? ""
            let surname = user.surname ?? ""
            return "\(name) \(surname)"
        }
        nameLabel.text = fullname
        emailLabel.text = user.email
        genderLabel.text = user.gender?.name
        birthdayLabel.text = user.birthday?.toStringShow
        phoneLabel.text = user.phone?.toString
        addressLabel.text = user.address?.toString
        profileImageView.imageUrl = user.imageURL
        tableView.reloadData()
    }
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func userNotSigned() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        if let vc = loginStoryboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            let navController = UINavigationController(rootViewController: vc)
            self.present(navController, animated: true, completion: {
                self.tabBarController?.selectedIndex = 0
            })
        }
        
        
    }
    
}

