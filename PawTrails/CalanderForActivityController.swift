//
//  CalanderForActivityController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 01/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class CalanderForActivityController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.maximumDate = Date()
        
   
    }

    @IBAction func doneBtnPressed(_ sender: Any) {
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
