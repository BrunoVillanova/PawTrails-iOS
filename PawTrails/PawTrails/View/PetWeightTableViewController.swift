//
//  PetWeightTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetWeightTableViewController: UITableViewController {

//    @IBOutlet weak var kgCell: UITableViewCell!
//    @IBOutlet weak var lbsCell: UITableViewCell!
    @IBOutlet weak var weightAmountTextField: UITextField!
    
    var parentEditor: AddEditPetPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weightAmountTextField.text = parentEditor.pet.weightString
        weightAmountTextField.becomeFirstResponder()
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        
        
        if let textAmount = weightAmountTextField.text {
            if let amount = Double(textAmount) {
                if amount > Constants.maxWeight {
                    alert(title: "", msg: "This weight is too high")
                }else{
                    set(amount)
                }
            }else{
                weightAmountTextField.shake()
            }
        }else{
            set(nil)
        }
    }
    
    func set(_ weight: Double?){
        parentEditor.pet.weight = weight
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)

    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneAction(nil)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
