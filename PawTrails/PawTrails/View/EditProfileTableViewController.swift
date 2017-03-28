//
//  EditProfileTableViewController.swift
//  Snout
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, EditProfileView , UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {


    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    fileprivate let presenter = EditProfilePresenter()
    
    fileprivate let imagePicker = UIImagePickerController()
    
    fileprivate let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self)
        
        tableView.tableFooterView = UIView()
        
        profileImage.circle()
       
        imagePicker.delegate = self
    }
    
    deinit {
        self.presenter.deteachView()
    }

    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        self.presenter.save()
    }
        
    // MARK: - EditProfileView

    func loadData(user:User, phone:_Phone?, address:_Address?) {
        
        let name = user.name ?? ""
        let surname = user.surname ?? ""
        
        nameLabel.text = "\(name) \(surname)"
        emailLabel.text = user.email
        genderLabel.text = Gender.build(code: user.gender)?.name
        
        if let date = user.birthday as? Date {
            birthdayLabel.text = date.toStringShow
        }
        
        phoneLabel.text = phone?.toString
        addressLabel.text = address?.toString        
    }
    
    func saved() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func errorMessage(_ error: ErrorMsg) {
        self.alert(title: error.title, msg: error.msg)
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = chosenImage
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case is NameTableViewController: (segue.destination as! NameTableViewController).parentEditor = presenter
            break
        case is EmailTableViewController: (segue.destination as! EmailTableViewController).parentEditor = presenter
            break
        case is GenderTableViewController: (segue.destination as! GenderTableViewController).parentEditor = presenter
            break
        case is BirthdayViewController: (segue.destination as! BirthdayViewController).parentEditor = presenter
            break
        case is PhoneTableViewController: (segue.destination as! PhoneTableViewController).parentEditor = presenter
            break
        case is AddressTableViewController: (segue.destination as! AddressTableViewController).parentEditor = presenter
            break
        default: break
        }
    }

    
    //MARK:- UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (photo) in
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default, handler: { (galery) in
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }



























}
