//
//  SettingsTableViewController.swift
//  Snout
//
//  Created by Marc Perello on 23/03/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SettingsView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sharedLocationSwitch: UISwitch!
    
    fileprivate let presenter = SettingsPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
    }
    
    deinit {
        presenter.deteachView()
    }
    
    @IBAction func shareLocationValueChanged(_ sender: UISwitch) {
        presenter.shareLocation(value: sender.isOn)
    }

    // MARK: - SettingsView
    
    func loadUser(name: String?, image: Data?, sharedLocation: Bool) {
        nameLabel.text = name
        if let image = image {
            profileImageView.image = UIImage(data: image)
        }
        sharedLocationSwitch.setOn(sharedLocation, animated: true)
    }
        
    func userNotSigned() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {
            self.present(vc, animated: true, completion: { 
                self.tabBarController?.selectedIndex = 0
            })
        }
    }
    
    func errorMessage(_ error: errorMsg) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
