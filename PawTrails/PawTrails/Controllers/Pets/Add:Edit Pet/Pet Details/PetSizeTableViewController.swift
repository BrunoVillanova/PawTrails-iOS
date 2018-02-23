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
        
        if let size = parentEditor.pet.size {
            switch size {
                case .small:
                    smallCell.accessoryType = .checkmark
                    break
                case .medium:
                    mediumCell.accessoryType = .checkmark
                    break
                case .large:
                    largeCell.accessoryType = .checkmark
                    break
            }
        }
    }

    
 
    @IBAction func doneAction(_ sender: Any) {
        var size: PetSize?
        
        if smallCell.accessoryType == .checkmark {
            size = .small
        } else if mediumCell.accessoryType == .checkmark {
            size = .medium
        }else if largeCell.accessoryType == .checkmark {
            size = .large
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
