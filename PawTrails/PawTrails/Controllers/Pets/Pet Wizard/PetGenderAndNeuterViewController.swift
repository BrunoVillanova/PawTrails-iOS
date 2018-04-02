//
//  PetGenderAndNeuterViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 02/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PetGenderAndNeuterViewController: PetWizardStepViewController {

    @IBOutlet weak var neuteredYesButton: UIButton!
    @IBOutlet weak var neuteredNoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
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
    
    override func nextButtonVisible() -> Bool {
        return true
    }
}
