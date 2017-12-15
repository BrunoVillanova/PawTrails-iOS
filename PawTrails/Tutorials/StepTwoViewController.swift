//
//  StepTwoViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class StepTwoViewController: UIViewController {
    
    
    var deviceCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func ContinouBtnPressed(_ sender: Any) {
        guard let deviceCode = self.deviceCode else {return}
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditPetDetailsTableViewController") as? AddEditPetDetailsTableViewController {
            vc.deviceCode = deviceCode
            let rootController = UINavigationController(rootViewController: vc)
            self.present(rootController, animated: true, completion: nil)
        }
    }
}
