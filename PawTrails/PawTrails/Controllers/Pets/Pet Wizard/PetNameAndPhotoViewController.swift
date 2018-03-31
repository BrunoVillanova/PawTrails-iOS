//
//  PetNameAndPhotoViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 30/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PetNameAndPhotoViewController: PetWizardStepViewController {

    fileprivate let imagePicker = UIImagePickerController()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var petPhotoView: UIView!
    @IBOutlet weak var petPhotoImageView: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        
        petPhotoView.layer.cornerRadius = petPhotoView.frame.size.height/2.0
        petPhotoView.layer.borderWidth = 1
        petPhotoView.layer.borderColor = PTConstants.colors.newLightGray.cgColor
        petPhotoImageView.layer.cornerRadius = petPhotoView.frame.size.height/2.0
        
        imagePicker.delegate = self
        
        self.nextButton.isEnabled = false
        
        petNameTextField.rx.text
            .asObservable()
            .subscribe(onNext: { value in
                self.pet!.name = value
                self.nextButton.isEnabled = value!.count > 0
            })
            .disposed(by: disposeBag)
    }

    @IBAction func selectPetPhotoButtonTapped(_ sender: Any) {
        alert(imagePicker)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        self.delegate?.stepCompleted(pet: self.pet!)
    }
}

extension PetNameAndPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            petPhotoImageView.image = chosenImage
            
            if var pet = self.pet {
                pet.image = chosenImage.encoded
            }
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
