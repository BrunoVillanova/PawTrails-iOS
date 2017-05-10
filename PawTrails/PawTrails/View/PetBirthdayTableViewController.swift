//
//  PetBirthdayTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetBirthdayTableViewController: UITableViewController {

    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    var parentEditor: AddEditPetPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthdayPicker.maximumDate = Date()
        
        if let birthday = parentEditor.getBirthday() {
            birthdayPicker.setDate(birthday, animated: false)
        }
        
        birthdayLabel.text = birthdayPicker.date.toStringShow
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        parentEditor.set(birthday: birthdayPicker.date)
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func datepickerValueChanged(_ sender: UIDatePicker) {
        birthdayLabel.text = sender.date.toStringShow
    }
    
}
