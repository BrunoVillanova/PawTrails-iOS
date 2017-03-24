//
//  BirthdayViewController.swift
//  Snout
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var parentEditor: EditProfilePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let birthday = parentEditor.getBirthday() {
            datePicker.setDate(birthday, animated: true)
        }
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        parentEditor.set(birthday: datePicker.date)
        parentEditor.refresh()
        view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }

}
