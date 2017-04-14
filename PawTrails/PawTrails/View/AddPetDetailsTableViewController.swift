//
//  AddPetDetailsTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddPetDetailsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AddPetView {

    fileprivate var headerView: UIView!
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate let presenter = AddPetPresenter()
    
    var deviceCode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imageButton.round()
        presenter.attachView(self)
        presenter.set(deviceCode: deviceCode)
    }

    deinit {
        presenter.deteachView()
    }
    
    @IBAction func editImageAction(_ sender: UIButton) {
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

    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        //save
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            doneAction(nil)
        }
    }
    
    //MARK: - AddPetView
    
    func load(pet: _pet) {
        nameLabel.text = pet.name
        typeLabel.text = pet.type
        genderLabel.text = pet.gender?.name
        breedLabel.text = pet.breed
        birthdayLabel.text = pet.birthday?.toStringShow
        weightLabel.text = pet.weight?.toString()
        tableView.reloadData()
    }
    
    func created() {
        dismiss(animated: true, completion: nil)
    }
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
    }

    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageButton.setBackgroundImage(chosenImage, for: .normal)
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case is PetNameTableViewController: (segue.destination as! PetNameTableViewController).parentEditor = presenter
            break
        case is PetTypeTableViewController: (segue.destination as! PetTypeTableViewController).parentEditor = presenter
            break
        case is PetGenderTableViewController: (segue.destination as! PetGenderTableViewController).parentEditor = presenter
            break
        case is PetBreedTableViewController: (segue.destination as! PetBreedTableViewController).parentEditor = presenter
            break
        case is PetBirthdayTableViewController: (segue.destination as! PetBirthdayTableViewController).parentEditor = presenter
            break
        case is PetWeightTableViewController: (segue.destination as! PetWeightTableViewController).parentEditor = presenter
            break
        default: break
        }
    }

}
