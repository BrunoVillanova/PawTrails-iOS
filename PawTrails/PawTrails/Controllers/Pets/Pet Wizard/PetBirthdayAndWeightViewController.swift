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
        let ruler = PTRulerSlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 24), scrollP:61, scrollQ:8600, scaleP: 0, scaleQ: 100)
        ruler.delegate = self
        weightSliderContainerView.addSubview(ruler)
        
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

    fileprivate func validate() {
        if let _ = self.pet?.birthday, let _ = self.pet?.weight {
            self.delegate?.stepCompleted(completed: true, pet: self.pet!)
        } else  {
            self.delegate?.stepCompleted(completed: false, pet: self.pet!)
        }
    }
}

extension PetBirthdayAndWeightViewController: SliderDelegate {
    func sliderDidScroll(value: Double) {
        
        weightLabel.text = " ~\(value.rounded(toPlaces: 2)) Kg"
        poundLabel.text = " \(PTUnitConversion.KgToLBS(weight: value).shortValue) lbs"
        
        self.pet!.size = PetSize.medium
        self.pet!.weight = value
        self.validate()
    }
}
