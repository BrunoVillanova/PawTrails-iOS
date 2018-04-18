//
//  PetBirthdayAndWeightViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 02/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class PetBirthdayAndWeightViewController: PetWizardStepViewController {

    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var weightSliderContainerView: UIView!
    @IBOutlet weak var poundLabel : UILabel!
    @IBOutlet weak var weightLabel : UILabel!
    
    let birthdayDatePicker = UIDatePicker()
    final let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let birthday = self.pet!.birthday {
            birthdayDatePicker.setDate(birthday, animated: false)
            birthdayTextField.text = birthday.toStringShow
        }
    }
    
    override func nextButtonVisible() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        
        addWightSlider()
        
        birthdayDatePicker.maximumDate = Date()
        birthdayDatePicker.datePickerMode = .date
        birthdayTextField.inputView = birthdayDatePicker
        
        birthdayDatePicker.rx.value
            .asObservable()
            .subscribe(onNext: { date in
                self.pet!.birthday = date
                self.validate()
                self.birthdayTextField.text = date.toStringShow
            }).disposed(by: disposeBag)
    }
    
    fileprivate func addWightSlider() {
        
        var startPosition = 0.0
        
        switch UIDevice.current.screenType {
        case .iPhones_6_6s_7_8:
            startPosition = 71.25
        case .iPhones_6Plus_6sPlus_7Plus_8Plus:
            startPosition = 52
        case .iPhoneX :
            startPosition = 71.0
        case .iPhones_5_5s_5c_SE:
            startPosition = 80
        case .iPhone4_4S:
            startPosition = 80
        default:
            startPosition = 80
        }
        
        let ruler = PTRulerSlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 24), scrollP:startPosition, scrollQ:8600, scaleP: 0, scaleQ: 100)
        ruler.delegate = self
        weightSliderContainerView.addSubview(ruler)
    }

    fileprivate func validate() {
        if let _ = self.pet?.birthday, let _ = self.pet?.weight {
            self.delegate?.stepCompleted(completed: true, pet: self.pet!)
        } else  {
            self.delegate?.stepCompleted(completed: false, pet: self.pet!)
        }
    }
}

extension PetBirthdayAndWeightViewController: SliderDelegate {
    func sliderDidScroll(valueInKg: Double) {
        
        //Display weight
        weightLabel.text = "~\(valueInKg.rounded(toPlaces: 2)) Kg"
        poundLabel.text = "\(PTUnitConversion.KgToLBS(weight: valueInKg).rounded(toPlaces: 2)) lbs"
        
        //Set selected weight
        //self.pet!.size = PetSize.medium
        self.pet!.weight = valueInKg.rounded(toPlaces: 2)  // Kg
        self.validate()
    }
}
