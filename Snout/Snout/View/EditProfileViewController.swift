//
//  EditProfileViewController.swift
//  Snout
//
//  Created by Marc Perello on 09/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let fieldsCells = ["Name", "Surname", "Email", "Phone"]
    let actionCells = [("Change Password",UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)),("Log Out",UIColor.red)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditProfileViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return fieldsCells.count
        default: return actionCells.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as! imageCell
            return cell
        }else if indexPath.section == 1 {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "BasicImageCell") as! basicImageCell
            cell1.textField.placeholder = fieldsCells[indexPath.row]
            return cell1
        }else {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "ActionCell") as! actionCell
            cell2.actionLabel.text = actionCells[indexPath.row].0
            cell2.actionLabel.textColor = actionCells[indexPath.row].1
            return cell2
        }
    }
}

extension EditProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            self.present(vc, animated: true, completion: nil)
        }else if indexPath.section == 2 && indexPath.row == 1 {
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to log out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                _ = AuthManager.Instance.signOut()
                UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ?  160.0 : 44.0
    }
    
}

class imageCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changeButton: UIButton!
}

class basicImageCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
}

class actionCell: UITableViewCell {
    @IBOutlet weak var actionLabel: UILabel!
}
