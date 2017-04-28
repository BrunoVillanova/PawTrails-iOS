//
//  AddEditPetDetailsTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddEditPetDetailsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AddEditPetView {

    fileprivate var headerView: UIView!

    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate let presenter = AddEditPetPresenter()
    
    var deviceCode: String!
    var pet: Pet!
    var parentEditor:PetProfileTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pet != nil {
            navigationItem.title = "Edit"
            navigationItem.prompt = pet.name
        }
        
        imagePicker.delegate = self
        petImageView.circle()
        presenter.attachView(self, pet)
    }

    deinit {
        presenter.deteachView()
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        presenter.done()
    }
    
    @IBAction func neutredValueChanged(_ sender: UISwitch) {
        presenter.set(neutred: sender.isOn)
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            doneAction(nil)
        }else if indexPath.section == 0 && indexPath.row == 0 {
            alert(imagePicker)
        }
    }
    
    //MARK: - AddEditPetView
    
    func loadPet() {
        if let imageData = presenter.getImageData() as Data? {
            petImageView.image = UIImage(data: imageData)
        }
        nameLabel.text = presenter.getName()
        typeLabel.text = presenter.getTypeText()
        genderLabel.text = presenter.getGender()?.name
        breedLabel.text = presenter.getBreedsText()
        birthdayLabel.text = presenter.getBirthday()?.toStringShow
        weightLabel.text = presenter.getWeight()?.toString()
        tableView.reloadData()
    }
    
    func doneSuccessfully() {
        if pet == nil {
            dismiss(animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func errorMessage(_ error: ErrorMsg) {
        alert(title: error.title, msg: error.msg)
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
            petImageView.image = chosenImage
            presenter.set(imageData: chosenImage.encoded)
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
        case is PetBreedViewController: (segue.destination as! PetBreedViewController).parentEditor = presenter
            break
        case is PetBirthdayTableViewController: (segue.destination as! PetBirthdayTableViewController).parentEditor = presenter
            break
        case is PetWeightTableViewController: (segue.destination as! PetWeightTableViewController).parentEditor = presenter
            break
        default: break
        }
    }

}
