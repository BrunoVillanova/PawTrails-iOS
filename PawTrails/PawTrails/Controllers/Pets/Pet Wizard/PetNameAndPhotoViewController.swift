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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let petName = self.pet?.name, petName.count > 0 {
            self.delegate?.stepCompleted(completed: true, pet: self.pet!)
        } else  {
            self.delegate?.stepCompleted(completed: false, pet: self.pet!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func nextButtonVisible() -> Bool {
        return true
    }
    
    fileprivate func initialize() {
        
        self.showNextButton = true
        
        petPhotoView.layer.cornerRadius = petPhotoView.frame.size.height/2.0
        petPhotoView.layer.borderWidth = 1
        petPhotoView.layer.borderColor = PTConstants.colors.newLightGray.cgColor
        petPhotoImageView.layer.cornerRadius = petPhotoView.frame.size.height/2.0
        
        imagePicker.delegate = self
        

        
        petNameTextField.rx.text
            .asObservable()
            .subscribe(onNext: { value in
                if let value = value, value.count > 0 {
                    self.pet!.name = value
                    self.delegate?.stepCompleted(completed: true, pet: self.pet!)
                } else {
                    self.delegate?.stepCompleted(completed: false, pet: self.pet!)
                }
            })
            .disposed(by: disposeBag)
    }


    @IBAction func selectPetPhotoButtonTapped(_ sender: Any) {
        alert(imagePicker)
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
