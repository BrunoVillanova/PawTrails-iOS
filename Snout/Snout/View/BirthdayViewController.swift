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
    
    var parentEditor: EditProfileTableViewController!
    var birthday: Date? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if birthday != nil {
            datePicker.setDate(birthday!, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        parentEditor.setBithdate(datePicker.date)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
