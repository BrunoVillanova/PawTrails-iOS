//
//  PetSizeTableViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 04/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetSizeTableViewController: UITableViewController {
    @IBOutlet var sizeTableView: UITableView!
    
    @IBOutlet weak var smallCell: UITableViewCell!
    
    @IBOutlet weak var largeCell: UITableViewCell!
    @IBOutlet weak var mediumCell: UITableViewCell!
    
    var parentEditor: AddEditPetPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = parentEditor.pet.size
            if size == 0 {
                smallCell.accessoryType = .checkmark
            } else if size == 1 {
                mediumCell.accessoryType = .checkmark
            } else if size == 2 {
                largeCell.accessoryType = .checkmark
            }
    }

    
 
    @IBAction func doneAction(_ sender: Any) {
        var size: Int?
        
        if smallCell.accessoryType == .checkmark {
            size = 0
        } else if mediumCell.accessoryType == .checkmark {
            size = 1
        }else if largeCell.accessoryType == .checkmark {
            size = 2
        }
        
        if let size = size {
            parentEditor.pet.size = size
        }
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            
            switch cell {
                            case smallCell:
                                smallCell.accessoryType = .checkmark
                                mediumCell.accessoryType = .none
                                largeCell.accessoryType = .none
                            break
            case mediumCell:
                smallCell.accessoryType = .none
                mediumCell.accessoryType = .checkmark
                largeCell.accessoryType = .none
                break
                
            case largeCell:
                smallCell.accessoryType = .none
                mediumCell.accessoryType = .none
                largeCell.accessoryType = .checkmark
                break
                
            default:
                break
            }
        }
    }
    

}
