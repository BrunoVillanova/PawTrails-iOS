//
//  StepThreeViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class StepThreeViewController: UIViewController {
    
    var petId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func continoutBtnPressed(_ sender: Any) {
        
        let StepThreeViewController = storyboard?.instantiateViewController(withIdentifier: "GettingLocationViewController") as! GettingLocationViewController
        self.present(StepThreeViewController, animated: true, completion: nil)
    }
}
