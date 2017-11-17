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
    @IBOutlet weak var neuteredSwitch: UISwitch!
    
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate let presenter = AddEditPetPresenter()
    
    var deviceCode: String!
    var pet: Pet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = pet?.name {
            navigationItem.title = "Edit \(name)"
        }
        imagePicker.delegate = self
        petImageView.circle()
        presenter.attachView(self, pet, deviceCode)
        NotificationManager.instance.post(Event())
}
    
    

    deinit {
        presenter.deteachView()
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        presenter.done()
    }
    
    @IBAction func neuteredValueChanged(_ sender: UISwitch) {
        presenter.pet.neutered = sender.isOn
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
        if let imageData = presenter.imageData {
            petImageView.image = UIImage(data: imageData)
        }else if let imageData = presenter.pet.image {
            petImageView.image = UIImage(data: imageData)
        }
        nameLabel.text = presenter.pet.name
        typeLabel.text = presenter.pet.typeString
        genderLabel.text = presenter.pet.gender?.name
        breedLabel.text = presenter.pet.breedsString
        birthdayLabel.text = presenter.pet.birthday?.toStringShow
        weightLabel.text = presenter.pet.weightWithUnitString
        neuteredSwitch.setOn(presenter.pet.neutered , animated: true)
        tableView.reloadData()
    }
    
    func doneSuccessfully() {
        if pet == nil {
            dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "petAdded"), object: nil)
            self.alert(title: "", msg: "Your request has been processed", type: .blue, disableTime: 3, handler: nil)
        }else{
            if let navigation = (navigationController?.viewControllers.first(where: { $0 is PetsViewController }) as? PetsViewController) {
                    navigation.reloadPetsAPI()

                self.alert(title: "", msg: "Your request has been processed", type: .blue, disableTime: 3, handler: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "petAdded"), object: nil)

                }
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
        let window = UIApplication.shared.keyWindow?.subviews.last
        window?.removeFromSuperview()

    }
    

    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            petImageView.image = chosenImage
            presenter.set(image: chosenImage.encoded)
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
