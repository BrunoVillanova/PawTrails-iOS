//
//  CalanderForActivityController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 01/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

protocol DateDelegate {
    func date(date: Date)
}

class CalanderForActivityController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    
     var delegate: DateDelegate?
     var date: Date?
    
    var parentController: EditUserProfileTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide the future dates
        self.datePicker.maximumDate = Date()

    }

    @IBAction func doneBtnPressed(_ sender: Any) {
     let mydate = self.datePicker.date
        self.delegate?.date(date: mydate)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

