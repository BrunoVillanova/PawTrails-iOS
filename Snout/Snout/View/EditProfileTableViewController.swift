//
//  EditProfileTableViewController.swift
//  Snout
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, EditProfileView, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    fileprivate let presenter = EditProfilePresenter()
    
    fileprivate let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        profileImageView.round()
        
        presenter.attachView(self)
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        genderTextField.inputView = picker
        
        imagePicker.delegate = self
    }
    
    deinit {
        self.presenter.deteachView()
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.presenter.save(nameTextField.text, surnameTextField.text, emailTextField.text)
    }
    
    @IBAction func changeImageAction(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
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
        self.presenter.setBirthday(date)
        self.birthdayLabel.text = date.toStringShow
    }
    
    func setPhone(_ number:String, cc:CountryCode){
        self.presenter.setPhone(number, cc)
        self.phoneLabel.text = self.presenter.phoneDescription
    }
    
    func setAddress(_ data:[String:String]){
        self.presenter.setAddress(data)
        self.addressLabel.text = self.presenter.addressDescription
    }
    
    // MARK: - EditProfileView

    func loadData(user: User) {
        self.nameTextField.text = user.name ?? ""
        self.surnameTextField.text = user.surname ?? ""
        self.emailTextField.text = user.email ?? ""
        self.genderLabel.text = Gender(code: user.gender ?? "").name()
        if let date = user.birthday as? Date {
            self.birthdayLabel.text = date.toStringShow
        }
        self.phoneLabel.text = self.presenter.phoneDescription
        self.addressLabel.text = self.presenter.addressDescription
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
        self.genderLabel.text = Gender(rawValue: row)?.name()
        self.presenter.setGender(Gender(rawValue: row)!)
        self.view.endEditing(true)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.count()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Gender(rawValue: row)?.name()
    }
    
    //MARK: - UIImagePickerControllerDelegate
//    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
////        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
////        myImageView.contentMode = .scaleAspectFit //3
////        myImageView.image = chosenImage //4
////        dismiss(animated:true, completion: nil) //5
//    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhoneViewController {
            (segue.destination as! PhoneViewController).parentEditor = self
            (segue.destination as! PhoneViewController).phone = self.presenter.getPhone()
        }else if segue.destination is BirthdayViewController {
            (segue.destination as! BirthdayViewController).parentEditor = self
            (segue.destination as! BirthdayViewController).birthday = self.presenter.getBirthday()
        }else if segue.destination is AddressViewController {
            (segue.destination as! AddressViewController).parentEditor = self
            (segue.destination as! AddressViewController).address = self.presenter.getAddress()
        }
    }





























}
