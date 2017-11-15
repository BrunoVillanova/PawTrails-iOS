//
//  AddPetUserViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 26/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddPetUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AddPetUserView {

    @IBOutlet weak var tableView: UITableView!
    
    var pet: Pet!
    
    fileprivate let presenter = AddPetUserPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self, pet: pet)
        navigationItem.title = "Add User"
    }

    deinit {
        presenter.deteachView()
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        view.endEditing(true)
        presenter.addPetUser(by: emailTextField()?.text, to: pet.id)
    }
    // MARK: - AddPetUserView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func loadFriends() {
        tableView.reloadData()
    }
    
    func successfullyAdded() {
        if let profile = navigationController?.viewControllers.first(where: { $0 is PetsViewController}) as? PetsViewController {
            profile.reloadPets()
            profile.tableView.reloadData()
            navigationController?.popToViewController(profile, animated: true)
        }
    }
    
    func emailFormat() {
        emailTextField()?.shake()
        emailTextField()?.becomeFirstResponder()
    }
    
    func emailTextField() -> UITextField? {
        if let emailRow = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? singleTextFormTableViewCell {
            return emailRow.textField
        }
        return nil
    }
    
    func beginLoadingContent() {
        showLoadingView()
    }
    
    func endLoadingContent() {
        let window = UIApplication.shared.keyWindow?.subviews.last
        window?.removeFromSuperview()
        
    }
        
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.friends.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : presenter.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath) as! singleTextFormTableViewCell
            cell.textField.delegate = self
            if #available(iOS 10.0, *) {
                cell.textField.textContentType = UITextContentType.emailAddress
            }
            if presenter.friends.count == 0 {
                cell.textField.becomeFirstResponder()
            }
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath)
            let friend = presenter.friends[indexPath.row]
            let fullName = (friend.name == nil && friend.name == nil) ?  friend.email ?? "-" : "\(friend.name ?? "") \(friend.surname ?? "")"
            cell.textLabel?.text = fullName
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? Message.instance.get(.newSharedUserEmailRequirements) : nil
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        let user = presenter.friends[indexPath.row]
        presenter.addPetUser(by: user.email, to: pet.id)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "New User" : "Friends"
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField() {
            doneAction(nil)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

public class singleTextFormTableViewCell: UITableViewCell  {
    @IBOutlet weak var textField: UITextField!
    
}
