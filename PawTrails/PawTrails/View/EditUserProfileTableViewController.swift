//
//  EditUserProfileTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class EditUserProfileTableViewController: UITableViewController, EditUserProfileView , UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {


    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var passwordChangeCell: UITableViewCell!
    
    var user:User!
    
    fileprivate let presenter = EditUserProfilePresenter()
    
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(self, user)
        
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
        
    // MARK: - EditUserProfileView

    func loadData() {
        
        let name = presenter.getName() ?? ""
        let surname = presenter.getSurName() ?? ""
        
        nameLabel.text = "\(name) \(surname)"
        emailLabel.text = presenter.getEmail()
        genderLabel.text = presenter.getGender()?.name
        birthdayLabel.text = presenter.getBirthday()?.toStringShow
        
        phoneLabel.text = presenter.getPhone()?.toString
        addressLabel.text = presenter.getAddress()?.toString
        
        if let imageData = presenter.getImage()  {
            profileImage.image = UIImage(data: imageData as Data)
        }
        
        if presenter.socialMediaLoggedIn() {
            emailCell.accessoryType = .none
            emailCell.selectionStyle = .none
            emailCell.isUserInteractionEnabled = false
            passwordChangeCell.isHidden = true
        }
    }
    
    func saved() {
        _ = self.navigationController?.popViewController(animated: true)
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
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            if let data = chosenImage.encoded {
                if data.count <= Constants.maxImageSize {
                    profileImage.image = chosenImage
                    presenter.set(image: data)
                }else{
                    alert(title: "Couldn't Set Image", msg: "Image size too big, try a smaller image")
                }
            }
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
