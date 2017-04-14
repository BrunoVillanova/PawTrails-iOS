//
//  PetProfileTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 24/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetProfileTableViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    var pet:_pet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        

        
//        let birthdayPicker = UIDatePicker()
//        birthdayPicker.datePickerMode = .date
//
//        let toolBar = UIToolbar()
//        toolBar.items = [ UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil), UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)]
//        
//        birthdayTextField.inputView = birthdayPicker
//        birthdayTextField.inputAccessoryView = toolBar
    }

    @IBAction func changePhotoAction(_ sender: UIButton) {
        
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
