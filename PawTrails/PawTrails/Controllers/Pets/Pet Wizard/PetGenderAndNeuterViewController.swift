//
//  PetGenderAndNeuterViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 02/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PetGenderAndNeuterViewController: PetWizardStepViewController {

    @IBOutlet weak var genderFemaleButton: UIButton!
    @IBOutlet weak var genderMaleButton: UIButton!
    @IBOutlet weak var neuteredYesButton: UIButton!
    @IBOutlet weak var neuteredNoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        validate()
    }
    
    override func nextButtonVisible() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func initialize() {
        configureLayout()
    }

    fileprivate func configureLayout() {
        let buttons = [neuteredYesButton, neuteredNoButton]
    
        for button in buttons {
            button?.layer.cornerRadius = (button?.frame.size.height)!/2.0
        }
    }
    
    fileprivate func validate() {
        if let _ = self.pet?.gender {
            self.delegate?.stepCompleted(completed: true, pet: self.pet!)
        } else  {
            self.delegate?.stepCompleted(completed: false, pet: self.pet!)
        }
    }
    
    @IBAction func genderMaleButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        genderFemaleButton.isSelected = false
        self.pet!.gender = Gender.male
        validate()
    }
    
    @IBAction func genderFemaleButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        genderMaleButton.isSelected = false
        self.pet!.gender = Gender.female
        validate()
    }
    
    @IBAction func neuteredYesButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        neuteredNoButton.isSelected = false
        self.pet!.neutered = true
        validate()
    }
    
    @IBAction func neuteredNoButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        neuteredYesButton.isSelected = false
        self.pet!.neutered = false
        validate()
    }
}

class PTCircularButton : UIButton {
    
    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                self.border(color: .white, width: 4)
            } else {
                self.border(color: .clear, width: 0)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
//        self.circle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.circle()
    }
}
