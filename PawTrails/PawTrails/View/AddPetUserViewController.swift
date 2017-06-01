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
    
    var petName: String!
    var petId: Int16!
    
    fileprivate let presenter = AddPetUserPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        navigationItem.title = "Add User"
        navigationItem.prompt = petName

    }
    
    deinit {
        presenter.deteachView()
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        view.endEditing(true)
        presenter.addPetUser(by: emailTextField()?.text, to: petId)
    }
    // MARK: - AddPetUserView
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }
    
    func loadFriends() {
        tableView.reloadData()
    }
    
    func successfullyAdded() {
        if let parent = navigationController?.viewControllers.first(where: { $0 is PetsPageViewController}) as? PetsPageViewController {
            if let profile = parent.profileTableViewController {
                profile.reloadUsers()
            }
            navigationController?.popToViewController(parent, animated: true)
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
        hideLoadingView()
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
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        let user = presenter.friends[indexPath.row]
        presenter.addPetUser(by: user.email, to: petId)
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
