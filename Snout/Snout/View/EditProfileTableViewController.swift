//
//  EditProfileTableViewController.swift
//  Snout
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, EditProfileView, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    fileprivate let presenter = EditProfilePresenter()
    fileprivate let codes = ["undefined", "male", "female"]
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.presenter.attachView(self)
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.genderTextField.inputView = picker
        profileImageView.round()
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.presenter.save(name: nameTextField.text, surname: surnameTextField.text, email: emailTextField.text, gender: genderLabel.text)
    }
    
    @IBAction func changeImageAction(_ sender: UIButton) {
        self.alert(title: "Underconstruction", msg: "check later =)")
    }

    @IBAction func logoutAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            _ = AuthManager.Instance.signOut()
            UIApplication.shared.keyWindow?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setBithdate(_ date:Date){
        self.birthdayLabel.text = date.toStringShow
        self.user.date_of_birth = date.toStringServer
    }
    
    func setPhone(_ number:String, cc:CountryCode){
//        self.user.phone = Phone()
//        self.user.phone?.number = number
//        self.user.phone?.country_code = cc
        self.phoneLabel.text = cc.code! + " " + number
    }
    
    // MARK: - EditProfileView

    func loadData(user: User) {
        self.user = user
        self.nameTextField.text = user.name ?? ""
        self.surnameTextField.text = user.surname ?? ""
        self.emailTextField.text = user.email ?? ""
        self.genderLabel.text = user.gender ?? ""
        self.birthdayLabel.text = user.date_of_birth ?? ""
        if user.phone != nil {
            self.phoneLabel.text = user.phone!.country_code!.code! + " " + user.phone!.number!
        }
    }
    
    func emailFormat() {
        self.emailTextField.shake()
    }
    
    func saved() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func errorMessage(_ error: errorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderLabel.text = self.codes[row]
        self.view.endEditing(true)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return codes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return codes[row]
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhoneViewController {
            (segue.destination as! PhoneViewController).parentEditor = self
        }else if segue.destination is BirthdayViewController {
            (segue.destination as! BirthdayViewController).parentEditor = self
        }
    }





























}
