//
//  SettingsTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SettingsView {
    
    @IBOutlet weak var allNotificationsSwitch: UISwitch!
    
    fileprivate let presenter = SettingsPresenter()
    
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        loadUser()
    }
    
    deinit {
        presenter.deteachView()
    }

    @IBAction func allNotificationsValueChanged(_ sender: UISwitch) {
        self.presenter.changeNotification(value: sender.isOn)
    }
    
    func loadUser(){
        if let user = user {
            allNotificationsSwitch.isOn = user.notification
        }
    }
    
    // MARK: - SettingsView
    
    func userNotSigned() {

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.loadAuthenticationScreen()
        }
    }
    
    func notificationValueChangeFailed() {
        allNotificationsSwitch.isOn = !allNotificationsSwitch.isOn
    }
    
    func notificationValueChanged() {
        let value = allNotificationsSwitch.isOn ? "On" : "Off"
        self.alert(title: "", msg: "All Notifications turned \(value) successfully", type: .green)
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
    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
  
    let alert = UIAlertController(title: "Warning", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            self.presenter.logout()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    }
    
    

//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        if indexPath.section == 2 && indexPath.row == 0 {
//            
//            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to log out?", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//                self.presenter.logout()
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }

