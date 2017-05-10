//
//  SettingsTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SettingsView {
    
    
    fileprivate let presenter = SettingsPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
    }
    
    deinit {
        presenter.deteachView()
    }
    
    // MARK: - SettingsView
    
    func userNotSigned() {

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.loadAuthenticationScreen()
        }
        
    }
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
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

}
