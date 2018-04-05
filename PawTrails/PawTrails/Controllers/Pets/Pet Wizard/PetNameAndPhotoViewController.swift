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
import Toucan
import TOCropViewController
//import CropViewController

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
        if let petName = pet!.name, petName.count > 0 {
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
        imagePicker.allowsEditing = false
        
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
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (photo) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default, handler: { (galery) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension PetNameAndPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated:true, completion: nil)
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let cropViewController = TOCropViewController(croppingStyle: .circular, image: chosenImage)
            cropViewController.delegate = self
            present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PetNameAndPhotoViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        cropViewController.dismiss(animated: true, completion: nil)
        if let resizedImage = Toucan.Resize.resizeImage(image, size: CGSize(width: 400, height: 400)) {
            petPhotoImageView.image = resizedImage
            self.pet!.image = resizedImage.encoded
        }
    }
}

import SkyFloatingLabelTextField

class PTNiceTextField: SkyFloatingLabelTextField {

    var labelBackgroundLayer: CALayer?
    let marginLeft:CGFloat = 12
    let labelPadding:CGFloat = 8
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        borderStyle = .roundedRect
        titleFont = UIFont(name: "Montserrat-Regular", size: 10)!
        titleColor = .clear
        selectedTitleColor = .white
        lineHeight = 0
        lineColor = .clear
        selectedLineHeight = 0
        selectedLineColor = .clear
        titleFormatter = { $0 }
    }
    
    override func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let superRect = super.titleLabelRectForBounds(bounds, editing: editing)
        let newRect = CGRect(x: superRect.origin.x+marginLeft+labelPadding, y: superRect.origin.y-(superRect.size.height/2.0),
                             width: titleLabel.intrinsicContentSize.width, height: superRect.size.height)
        return newRect
    }

    
    override func editingChanged() {
        super.editingChanged()
        updateLayerForTitleLabel(titleLabel.frame)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        let titleHeight = self.titleHeight()

        let padding:CGFloat = 10
        let rect = CGRect(
            x: superRect.origin.x,
            y: padding,
            width: superRect.size.width,
            height: superRect.size.height + titleHeight + selectedLineHeight - padding
        )
        return rect
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding:CGFloat = 8
        let rect = CGRect(
            x: 8,
            y: 0,
            width: bounds.size.width,
            height: bounds.size.height + titleHeight() + selectedLineHeight - padding
        )
        return rect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if labelBackgroundLayer == nil {
            labelBackgroundLayer = CALayer()
            labelBackgroundLayer!.backgroundColor = PTConstants.colors.lightBlue.cgColor
            titleLabel.layer.masksToBounds = true
        }
    }
    
    fileprivate func updateLayerForTitleLabel(_ newRect: CGRect) {
        if let labelBackgroundLayer = labelBackgroundLayer {
            let newRect2 = CGRect(x: newRect.origin.x-labelPadding, y: newRect.origin.y,
                                  width: newRect.size.width+(2*labelPadding), height: newRect.size.height)
            labelBackgroundLayer.frame = newRect2
            labelBackgroundLayer.cornerRadius = labelBackgroundLayer.frame.size.height/2.0
            
            let isVisible = isTitleVisible()
            
            if isVisible {
                titleLabel.layer.superlayer?.insertSublayer(labelBackgroundLayer, below: titleLabel.layer)
            } else {
                labelBackgroundLayer.removeFromSuperlayer()
            }
        }
    }
}
