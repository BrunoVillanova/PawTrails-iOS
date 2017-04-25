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
        
        if let weight = parentEditor.getWeight() {
            
//            switch weight.unit {
//            case .kg: selectKg()
//                break
//            case .lbs: selectLbs()
//                break
//            }
            
            weightAmountTextField.text = "\(weight.amount)"
        }
        weightAmountTextField.becomeFirstResponder()

    }

    @IBAction func doneAction(_ sender: UIBarButtonItem?) {
        
        
        if let textAmount = weightAmountTextField.text {
            if let amount = Double(textAmount) {
                parentEditor.set(weight: Weight( amount, unit: .kg))
            }else{
                weightAmountTextField.shake()
            }
        }else{
            parentEditor.set(weight: nil)
        }
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            if indexPath.row == 0 {
//                selectKg()
//            }else if indexPath.row == 1 {
//                selectLbs()
//            }
//        }
    }
    
//    func selectKg(){
//        kgCell.accessoryType = .checkmark
//        lbsCell.accessoryType = .none
//    }
//    
//    func selectLbs(){
//        kgCell.accessoryType = .none
//        lbsCell.accessoryType = .checkmark
//    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneAction(nil)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
