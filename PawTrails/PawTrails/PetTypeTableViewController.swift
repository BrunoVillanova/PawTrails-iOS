//
//  PetTypeTableViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 11/04/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetTypeTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var catCell: UITableViewCell!
    @IBOutlet weak var dogCell: UITableViewCell!
    @IBOutlet weak var otherTextField: UITextField!
    
    var parentEditor: AddEditPetPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let typeName = parentEditor.getType() {
            
            if let type = Type.build(code: typeName) {
                switch type {
                case .cat: catCell.accessoryType = .checkmark
                    break
                case .dog: dogCell.accessoryType = .checkmark
                    break
                default:
                    otherTextField.text = typeName
                }
            }
        }
        
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        
        var type: String? = nil
        if catCell.accessoryType == .checkmark {
            type = "Cat"
        }else if dogCell.accessoryType == .checkmark {
            type = "Dog"
        }else if otherTextField.text != nil {
            type = otherTextField.text
        }
        if type != parentEditor.getType() {
            parentEditor.set(first: nil)
            parentEditor.set(second: nil)
        }
        parentEditor.set(type: type)
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        otherTextField.resignFirstResponder()
        if let cell = tableView.cellForRow(at: indexPath) {
            
            switch cell {
            case catCell:
                catCell.accessoryType = .checkmark
                dogCell.accessoryType = .none
                otherTextField.text = ""
                break
            case dogCell:
                catCell.accessoryType = .none
                dogCell.accessoryType = .checkmark
                otherTextField.text = ""
                break
            default:
                break
            }
        }
    }
    
    //MARK:- UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        catCell.accessoryType = .none
        dogCell.accessoryType = .none
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}
