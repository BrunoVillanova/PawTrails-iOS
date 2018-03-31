//
//  PetBreedViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 31/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PetBreedSelectViewController: PetWizardStepViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showNextButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func nextButtonVisible() -> Bool {
        return true
    }
}
