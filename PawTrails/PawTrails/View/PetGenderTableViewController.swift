//
//  PetGenderTableViewController.swift
//  
//
//  Created by Marc Perello on 11/04/2017.
//
//

import UIKit

class PetGenderTableViewController: UITableViewController {

    @IBOutlet weak var femaleCell: UITableViewCell!
    @IBOutlet weak var maleCell: UITableViewCell!
    
    var parentEditor: AddPetPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let gender = parentEditor.getGender() {
                switch gender {
                case .female: femaleCell.accessoryType = .checkmark
                    break
                case .male: maleCell.accessoryType = .checkmark
                default:
                    break
                }
            }

    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        var gender: Gender? = nil
        if femaleCell.accessoryType == .checkmark {
            gender = Gender.female
        }else if maleCell.accessoryType == .checkmark {
            gender = Gender.male
        }
        parentEditor.set(gender: gender)
        parentEditor.refresh()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            if femaleCell.accessoryType == .checkmark {
                femaleCell.accessoryType = .none
            }else{
                femaleCell.accessoryType = .checkmark
                maleCell.accessoryType = .none
            }
            break
        case 1:
            if maleCell.accessoryType == .checkmark {
                maleCell.accessoryType = .none
            }else{
                maleCell.accessoryType = .checkmark
                femaleCell.accessoryType = .none
            }        default:
            break
        }
    }
}
