//
//  PetWizardStepViewController.swift
//  PawTrails
//
//  Created by Bruno on 28/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

protocol PetWizardStepViewControllerDelegate {
    func stepCompleted(completed: Bool, pet: Pet)
    func stepCanceled(pet: Pet)
    func goToNextStep()
}

class PetWizardStepViewController: UIViewController {

    var pet: Pet?
    var delegate:PetWizardStepViewControllerDelegate?
    var showNextButton = false
    var rightBarButtonItem: UIBarButtonItem?
    
    func nextButtonVisible() -> Bool {
        return false
    }
}

