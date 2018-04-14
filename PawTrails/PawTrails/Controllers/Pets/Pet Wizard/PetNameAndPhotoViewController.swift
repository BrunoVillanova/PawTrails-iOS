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
                    self.pet!.name = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    self.delegate?.stepCompleted(completed: true, pet: self.pet!)
                } else {
                    self.delegate?.stepCompleted(completed: false, pet: self.pet!)
                }
            })
            .disposed(by: disposeBag)
        
        petNameTextField.delegate = self
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

extension PetNameAndPhotoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let currentText = textField.text {
            if (range.location == 0 && string == " ") || (range.location > 0 && currentText.hasSuffix(" ") && string == " ") {
                return false
            }
        }
        
        let maxLength = 50
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
   
        return newString.length <= maxLength
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
            self.pet!.image = UIImageJPEGRepresentation(resizedImage, 100)
        }
    }
}

import SkyFloatingLabelTextField

enum PTNiceTextFieldInputType {
    case generic, email
    
    func validate(_ text: String) -> Bool {
        return true
    }
    
    func transform(_ text: String) -> String {
        switch self {
        case .email:
            return text.lowercased()
        default:
            return text
        }
        
    }
}

class PTNiceTextField: SkyFloatingLabelTextField {

    var labelBackgroundLayer: CALayer?
    let borderLayer: CALayer = CALayer()
    let marginLeft:CGFloat = 16
    let labelPadding:CGFloat = 8
    var inputType: PTNiceTextFieldInputType = .generic
    
    override var inputView: UIView? {
        didSet {
            if inputView != nil, inputView is UIDatePicker || inputView is UIPickerView  {
              self.addKeyboardToolbarWithButtons(inputView!)
            }
        }
    }
    
    fileprivate func addKeyboardToolbarWithButtons(_ picker: UIView) {
        
        let keyboardToolBar = UIToolbar(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(picker.frame.size.width), height: CGFloat(25)))
        keyboardToolBar.sizeToFit()
        keyboardToolBar.barStyle = .default
        self.inputAccessoryView = keyboardToolBar
        let nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.resignFirstResponder))
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 14)!,NSForegroundColorAttributeName: PTConstants.colors.newRed]
        nextButton.setTitleTextAttributes(attributes, for: .normal)
        keyboardToolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), nextButton]
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        titleFont = UIFont(name: "Montserrat-Regular", size: 10)!
        titleColor = .clear
        selectedTitleColor = .white
        lineHeight = 0
        lineColor = .clear
        selectedLineHeight = 0
        selectedLineColor = .clear
        titleFormatter = { $0 }
        
        borderLayer.cornerRadius = 5
        borderLayer.borderWidth = 1
        borderLayer.borderColor = PTConstants.colors.lightGray.cgColor
        self.layer.insertSublayer(borderLayer, at: 0)
        
        if self.keyboardType == .emailAddress {
            inputType = .email
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: self)
    
    }

    @objc fileprivate func textFieldDidChange(notification:NSNotification) {
        if let text = self.text {
            self.text = inputType.transform(text)
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        setTitleVisible(true, animated: true, animationCompletion: nil)
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        setTitleVisible(false, animated: true, animationCompletion: nil)
        return result
    }
    
    override func setTitleVisible(_ titleVisible: Bool, animated: Bool, animationCompletion: ((Bool) -> Void)?) {
        super.setTitleVisible(titleVisible, animated: animated, animationCompletion: animationCompletion)
        labelBackgroundLayer?.isHidden = titleVisible ? false : true
        borderLayer.borderColor = titleVisible ? PTConstants.colors.lightBlue.cgColor : PTConstants.colors.lightGray.cgColor
    }

    override func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let superRect = super.titleLabelRectForBounds(bounds, editing: editing)
        let newRect = CGRect(x: superRect.origin.x+marginLeft+labelPadding, y: superRect.origin.y-(superRect.size.height/2.0),
                             width: titleLabel.intrinsicContentSize.width, height: superRect.size.height)
        updateLayerForTitleLabel(newRect)
        return newRect
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        let titleHeight = self.titleHeight()

        let padding:CGFloat = 10
        let rect = CGRect(
            x: superRect.origin.x + 16,
            y: padding,
            width: superRect.size.width,
            height: superRect.size.height + titleHeight + selectedLineHeight - padding
        )
        return rect
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding:CGFloat = 8
        let rect = CGRect(
            x: 16,
            y: 1,
            width: bounds.size.width,
            height: bounds.size.height + titleHeight() + selectedLineHeight - padding
        )
        return rect
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)

        let rect = CGRect(
            x: superRect.origin.x+16,
            y: superRect.origin.y-2,
            width: superRect.size.width,
            height: superRect.size.height
        )
        return rect
    }
    
    fileprivate func commonRect() -> CGRect {
        let rect = CGRect(
            x: 4,
            y: 0,
            width: bounds.size.width,
            height: bounds.size.height
        )
        return rect
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = CGRect(x: 0,
                                    y: 0,
                                    width: self.frame.size.width,
                                    height: self.frame.size.height)
    }
    
    fileprivate func updateLayerForTitleLabel(_ newRect: CGRect) {
        
        if labelBackgroundLayer == nil {
            labelBackgroundLayer = CALayer()
            labelBackgroundLayer!.backgroundColor = PTConstants.colors.lightBlue.cgColor
            labelBackgroundLayer!.isHidden = true
            titleLabel.layer.masksToBounds = true
        }
        
        if let labelBackgroundLayer = labelBackgroundLayer {
            let newRect2 = CGRect(x: newRect.origin.x-labelPadding,
                                  y: newRect.origin.y,
                                  width: newRect.size.width+(2*labelPadding),
                                  height: newRect.size.height)
            labelBackgroundLayer.frame = newRect2
            labelBackgroundLayer.cornerRadius = labelBackgroundLayer.frame.size.height/2.0
            titleLabel.layer.superlayer?.insertSublayer(labelBackgroundLayer, below: titleLabel.layer)
        }
    }
    
}
