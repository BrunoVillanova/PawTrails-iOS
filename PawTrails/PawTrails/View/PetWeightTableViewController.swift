//
//  PetWeightTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetWeightTableViewController: UITableViewController {

    @IBOutlet weak var kgCell: UITableViewCell!
    @IBOutlet weak var lbsCell: UITableViewCell!
    @IBOutlet weak var weightAmountTextField: UITextField!
    
    var parentEditor: AddPetPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let weight = parentEditor.getWeight() {

            
            switch weight.unit {
            case .kg: selectKg()
                break
            case .lbs: selectLbs()
                break
            }
            
            weightAmountTextField.text = "\(weight.amount)"
        }
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        
        parentEditor.set(weight: nil)
        if let textAmount = weightAmountTextField.text {
            if let amount = Double(textAmount) {
                let w = kgCell.accessoryType == .checkmark ? Weight(unit: .kg, amount: amount) : Weight(unit: .lbs, amount: amount)
                parentEditor.set(weight: w)
            }
        }
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                selectKg()
            }else if indexPath.row == 1 {
                selectLbs()
            }
        }
    }
    
    func selectKg(){
        kgCell.accessoryType = .checkmark
        lbsCell.accessoryType = .none
    }
    
    func selectLbs(){
        kgCell.accessoryType = .none
        lbsCell.accessoryType = .checkmark
    }
}
