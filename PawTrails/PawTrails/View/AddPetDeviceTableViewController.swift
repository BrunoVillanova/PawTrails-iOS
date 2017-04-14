//
//  AddPetDeviceTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 12/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class AddPetDeviceTableViewController: UITableViewController {

    @IBOutlet weak var deviceCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if deviceCodeTextField.text != nil {
            deviceCodeTextField.becomeFirstResponder()
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addPetDetails" && (deviceCodeTextField.text == nil || deviceCodeTextField.text != nil && deviceCodeTextField.text == "") {
            deviceCodeTextField.shake()
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is AddPetDetailsTableViewController {
            self.view.endEditing(true)
            (segue.destination as! AddPetDetailsTableViewController).deviceCode = deviceCodeTextField.text!
        }
    }
}
