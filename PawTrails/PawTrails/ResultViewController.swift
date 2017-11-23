//
//  ResultViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 19/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    var pet: Pet!
    var bscText: String?
    var weight: String?

    
    
    
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petImage: UiimageViewWithMask!
    @IBOutlet weak var bscLabel: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var showrecmBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIRepository.instance.loadPet(pet.id, callback: { (error, pet) in
            if error == nil, let pet = pet {
                self.pet = pet
            }
        })
        
        
        if let pet = pet, let bscescroe = bscText, let weights = weight {
            self.bscLabel.text = bscescroe
            self.weightLbl.text = weights
            self.petName.text = pet.name
            if let imageData = pet.image as Data? {
                petImage.image = UIImage(data: imageData)
            }else{
                petImage.image = nil
            }
        } else {
            self.bscLabel.text = ""
            self.weightLbl.text = ""
            self.petName.text = ""

        }
        
        scrollView.contentInset.bottom = 100
        restartBtn.border(color: UIColor.primary, width: 2)
        restartBtn.setTitleColor(UIColor.primary, for: .normal)
        restartBtn.backgroundColor = UIColor.white
        
        restartBtn.layer.cornerRadius = 25
        restartBtn.clipsToBounds = true
        
        showrecmBtn.layer.cornerRadius = 25
        showrecmBtn.clipsToBounds = true

        
        self.navigationItem.title = "Recommandation"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closedPress(sender:)))


    }

    @IBAction func showRecomBtnPressed(_ sender: UIButton) {
        
        if var pet = self.pet, let bcScore = self.bscText {
            
            if bcScore == "BCS 1" {
                pet.bcScore = 1
            } else if bcScore == "BCS 2" {
                pet.bcScore = 2
            } else if bcScore == "BCS 3" {
                pet.bcScore = 3
            }else if bcScore == "BCS 4" {
                pet.bcScore = 4
            }else if bcScore == "BCS 5" {
                pet.bcScore = 5
            }
            APIRepository.instance.save(pet, callback: { (error, pet) in
                if error == nil, let pet = pet {
                    print(pet.bcScore)
                } else {
                    self.alert(title: "", msg: "An error occured, please try again", type: .red, disableTime: 3, handler: nil)
                }
            })

        }
 
    }

    @IBAction func restartBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func closedPress(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    
    
    
}
