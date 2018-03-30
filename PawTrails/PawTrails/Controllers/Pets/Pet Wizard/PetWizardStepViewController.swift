//
//  PetWizardStepViewController.swift
//  PawTrails
//
//  Created by Bruno on 28/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

protocol PetWizardStepViewControllerDelegate {
    func stepCompleted(pet: Pet)
    func stepCanceled(pet: Pet)
}

class PetWizardStepViewController: UIViewController {

    var pet: Pet?
    var delegate:PetWizardStepViewControllerDelegate?
}
