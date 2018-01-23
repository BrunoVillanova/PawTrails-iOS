//
//  StepThreeViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class StepThreeViewController: UIViewController {
    
    var pet: Pet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
    }
    
    @IBAction func continoutBtnPressed(_ sender: Any) {
        
        let StepThreeViewController = storyboard?.instantiateViewController(withIdentifier: "GettingLocationViewController") as! GettingLocationViewController
        if let pet = pet {
            StepThreeViewController.pet = pet
        }
        self.navigationController?.pushViewController(StepThreeViewController, animated: true)
    }
}
