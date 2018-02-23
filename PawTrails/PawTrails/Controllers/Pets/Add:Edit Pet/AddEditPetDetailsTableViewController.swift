//
//  AddEditPetDetailsTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 03/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import GSMessages


class AddEditPetDetailsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AddEditPetView {
    
    fileprivate var headerView: UIView!
    
    @IBOutlet weak var changeDeviceId: UIButton!
    @IBOutlet weak var removePetButton: UIButton!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var neuteredSwitch: UISwitch!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var removePetView: UIView!
    
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate let presenter = AddEditPetPresenter()
    
    var deviceCode: String!
    var pet: Pet?
    var editingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editingMode = (pet != nil)
        
        if pet != nil {
            self.changeDeviceId.isHidden = false
        } else {
            self.changeDeviceId.isHidden = true
        }
        
        if editingMode, let name = pet?.name {
            navigationItem.title = "Edit \(name)"
        }
        
        removePetView.isHidden = !editingMode
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
        //        doneSuccessfully()
    }
    
    @IBAction func changeDeviceIdBtnPressed(_ sender: Any) {
        
        QRCodeScannerViewController.authorizeCameraWith {[weak self] (granted) in
            if granted, let strongSelf = self {
                let vc = QRCodeScannerViewController();
                vc.delegate = strongSelf;
                
                // Hide the status bar
//                strongSelf.statusBarShouldBeHidden = true
                UIView.animate(withDuration: 0.25) {
                    strongSelf.setNeedsStatusBarAppearanceUpdate()
                }
                
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navigationController.navigationBar.shadowImage = UIImage()
                navigationController.navigationBar.isTranslucent = true
                navigationController.navigationBar.backgroundColor = UIColor.clear
                navigationController.navigationBar.tintColor = UIColor.white
                
                let barButtonItem = UIBarButtonItem.init(title: "Close", style: UIBarButtonItemStyle.plain, target:strongSelf, action: #selector(strongSelf.closeScannerViewController))
                
                vc.navigationItem.setRightBarButton(barButtonItem, animated: true)
                
                strongSelf.present(navigationController, animated: true, completion: {
                    
                })
            }
        }
    }
    
    @IBAction func removePetBtnPressed(_ sender: Any) {
        
        print("removing Pet")
        //if self.currentUserId == self.petOwnerId && self.petOwnerId == self.appUserId {
            // Remove Pet
            self.popUpDestructive(title: "Remove \(self.pet?.name ?? "this pet")", msg: "If you proceed you will loose all the information of this pet.", cancelHandler: nil, proceedHandler: { (remove) in
                self.presenter.removePet(with: (self.pet?.id)!)
            })
        //}
        
    }
    
    @objc fileprivate func closeScannerViewController() {
        self.dismiss(animated: true, completion: nil)
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
    
    //MARK: - AddEditPetViewi l
    
    func loadPet() {
        
        if let petImageData = presenter.pet.image {
            petImageView.image = UIImage(data: petImageData)
        } else if let imageUrl = presenter.pet.imageURL {
            petImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: #imageLiteral(resourceName: "PetPlaceholderImage"), options: [.continueInBackground])
        }

        if let petSize = presenter.pet.size {
            self.sizeLbl.text = petSize.description
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
    
    func codeChanged() {
        self.dismiss(animated: true, completion: nil)
        self.showMessage("The Pet Device ID Has Been Changed Successfully", type: GSMessageType.info,  options: [
            .animation(.slide),
            .animationDuration(0.3),
            .autoHide(false),
            .cornerRadius(0.0),
            .height(44.0),
            .hideOnTap(false),
            //                .margin(.init(top: 64, left: 0, bottom: 0, right: 0)),
            //                .padding(.zero),
            .position(.top),
            .textAlignment(.center),
            .textNumberOfLines(0),
            ])
        
    }
    
    func petRemoved() {
        
        UIApplication.shared.keyWindow?.rootViewController!.showMessage("The pet has been deleted successfully", type: GSMessageType.info,  options: [
            .animation(.slide),
            .animationDuration(0.3),
            .autoHide(false),
            .cornerRadius(0.0),
            .height(44.0),
            .hideOnTap(true),
            .position(.top),
            .textAlignment(.center),
            .textNumberOfLines(0),
            ])
        
        if let petList = navigationController?.viewControllers.first(where: { $0 is PetsViewController}) as? PetsViewController {
            petList.reloadPets()
            navigationController?.popToViewController(petList, animated: true)
        }else{
            //This case can be : User tap on pet in Map and open the detail page.
            self.navigationController?.popToRootViewController(animated: true)
            
            //TODO: Reload the MAP to remove deleted pet.
        }
        
    }
    
    func doneSuccessfully() {
        
        if let presentingViewController = self.presentingViewController {
            let stepThreeViewController = self.storyboard?.instantiateViewController(withIdentifier: "StepThreeViewController") as! StepThreeViewController
            stepThreeViewController.pet = self.presenter.savedPet
            
            self.dismiss(animated: true, completion: {
                if presentingViewController is UINavigationController {
                    let navigationController = presentingViewController as! UINavigationController
                    navigationController.pushViewController(stepThreeViewController, animated: true)
                    stepThreeViewController.alert(title: "", msg: "You've added one pet", type: .green, disableTime: 3, handler: nil)
                }
            })
        }
//        if pet == nil {
//            let stepThreeViewController = storyboard?.instantiateViewController(withIdentifier: "StepThreeViewController") as! StepThreeViewController
//
//            stepThreeViewController.pet = presenter.savedPet
//            self.present(stepThreeViewController, animated: true, completion: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "petAdded"), object: nil)
//            self.alert(title: "", msg: "Your request has been processed", type: .blue, disableTime: 3, handler: nil)
//        }
        else{
            loadPet()
            if let navigation = (navigationController?.viewControllers.first(where: { $0 is PetsViewController }) as? PetsViewController) {
                navigation.reloadPets()
                self.alert(title: "", msg: "Your request has been processed", type: .blue, disableTime: 3, handler: nil)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "petAdded"), object: nil)
            
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
        case is PetSizeTableViewController: (segue.destination as! PetSizeTableViewController).parentEditor = presenter
        default: break
        }
    }
    
    fileprivate func goToNextStep(deviceCode: String) {
        guard let petid = self.pet?.id else {return}
        self.presenter.change(deviceCode, to: petid)
    }
}


extension AddEditPetDetailsTableViewController: QRCodeScannerViewControllerDelegate {
    
    func scanFinished(qrCodeScannerViewController: UIViewController, scanResult: String?, error: String?){
        
        if let error = error {
            self.alert(title: "=(", msg: error)
        } else if let scanResult = scanResult, qrCodeScannerViewController.presentingViewController != nil {
            qrCodeScannerViewController.dismiss(animated: true, completion: {
                self.goToNextStep(deviceCode: scanResult)
            })
        }
    }
    
}

