//
//  SettingsTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

typealias SetingsActionCallback = (_ sender: Any) -> Void

struct SettingsMenuItem {
    var title: String?
    var imageName: String?
    var viewController: ViewController?
    var isModal: Bool?
    var action: SetingsActionCallback?
}

extension SettingsMenuItem {
    init(_ title: String?, imageName: String?, viewController: ViewController? = nil, isModal: Bool? = false, action: SetingsActionCallback? = nil) {
        self.title = title
        self.imageName = imageName
        self.viewController = viewController
        self.isModal = isModal
        self.action = action
    }
}

class SettingsTableViewController: UITableViewController, SettingsView {
    
//    @IBOutlet weak var allNotificationsSwitch: UISwitch!
    
    
    fileprivate let presenter = SettingsPresenter()
    
    var user:User!
    
    fileprivate final let menuItems = [
    [ SettingsMenuItem("Change Password",
                 imageName: "changepassword",
                 viewController: ViewController.liveTracking),
        SettingsMenuItem("Notifications",
                 imageName: "notifications",
                 action: {sender in
                    if let sender = sender as? LeftMenuContentViewController {
                        sender.showComingSoonAlert("Device finder")
                    }
        })],
        [SettingsMenuItem("About PawTrails",
                 imageName: "aboutIcon",
                 viewController: ViewController.myPets),
        SettingsMenuItem("Privacy Policy of PawTrails",
                         imageName: "privacy",
                         viewController: ViewController.myPets),
         SettingsMenuItem("Terms and conditions",
                         imageName: "updateIcon",
                         viewController: ViewController.myPets)],
        [SettingsMenuItem("Send feedback",
                         imageName: "sendfeedback",
                         viewController: ViewController.myPets),
        SettingsMenuItem("Check for update",
                         imageName: "updateIcon",
                         viewController: ViewController.myPets),
        SettingsMenuItem("Logout",
                         imageName: "logout",
                         action: {sender in
                            if let sender = sender as? LeftMenuContentViewController {
                                sender.showComingSoonAlert("Device finder")
                            }
        })]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        loadUser()
        
    }
    
    deinit {
        presenter.deteachView()
    }

//    @IBAction func allNotificationsValueChanged(_ sender: UISwitch) {
//        self.presenter.changeNotification(value: sender.isOn)
//    }
    
    func loadUser(){
//        if let user = user {
////            allNotificationsSwitch.isOn = user.notification
//        }
    }
    
    // MARK: - SettingsView
    
    func userNotSigned() {

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.loadAuthenticationScreen()
        }
    }
    
    func notificationValueChangeFailed() {
//        allNotificationsSwitch.isOn = !allNotificationsSwitch.isOn
    }
    
    func notificationValueChanged() {
//        let value = allNotificationsSwitch.isOn ? "On" : "Off"
//        self.alert(title: "", msg: "All Notifications turned \(value) successfully", type: .green)
    }
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        hideLoadingView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 2
        case 1:
            return 3
        case 2:
            return 3
        default:
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    //, let user = self.users
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SettingsTableViewCell{
            
            var itemArray = menuItems[indexPath.section]
            let settingsItem = itemArray[indexPath.row] as SettingsMenuItem
            cell.titleLabel.text = settingsItem.title
            cell.iconImage.image = UIImage(named:settingsItem.imageName!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nothing", for: indexPath)
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to log out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.presenter.logout()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {

        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.presenter.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}




