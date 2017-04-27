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
    
    var pet:Pet!
    
    fileprivate let presenter = AddPetUserPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        navigationItem.title = "Add User"
        navigationItem.prompt = pet.name
    }
    
    deinit {
        presenter.deteachView()
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        presenter.addPetUser(by: emailTextField()?.text)
    }
    // MARK: - AddPetUserView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func loadFriends() {
//        tableView.reloadData()
    }
    
    func successfullyAdded() {
        popUp(title: "Success", msg: "The user has been added properly to the pet")
    }
    
    func emailFormat() {
        emailTextField()?.shake()
    }
    
    func emailTextField() -> UITextField? {
        if let emailRow = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? singleTextFormTableViewCell {
            return emailRow.textField
        }
        return nil
    }
    
    // MARK: - Connection Notifications
    
    func connectedToNetwork() {
        hideNotification()
    }
    
    func notConnectedToNetwork() {
        showNotification(title: Message.Instance.connectionError(type: .NoConnection), type: .red)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.friends.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if presenter.friends.count > 0 {
            return section == 0 ? 1 : presenter.friends.count
//        }else{
//            return 1
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath) as! singleTextFormTableViewCell
            cell.textField.delegate = self
            if presenter.friends.count == 0 {
                cell.textField.becomeFirstResponder()
            }
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath)
            let friend = presenter.friends[indexPath.row]
            let fullName = "\(friend.name ?? "") \(friend.surname ?? "")"
            cell.textLabel?.text = fullName
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "New User" : "Friends"
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
//    texfield
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

public class singleTextFormTableViewCell: UITableViewCell  {
    @IBOutlet weak var textField: UITextField!
    
}
