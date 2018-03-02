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
    
    
    let idealColor = UIColor(red: 112/255, green: 163/255, blue: 8/255, alpha: 1)
    let obseAndVeryThinColor = UIColor(red: 212/255, green: 20/255, blue: 61/255, alpha: 1)
    let threeColor = UIColor(red: 212/255, green: 20/255, blue: 61/255, alpha: 1)

    
    @IBOutlet weak var bcScoreLbl: UILabel!
    @IBOutlet weak var reccomTextView: UITextView!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petImage: PTBalloonImageView!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        

        
        APIRepository.instance.loadPet(pet.id, callback: { (error, pet) in
            if error == nil, let pet = pet {
                self.pet = pet
            }
        })
        
        
        if let pet = pet, let bCScore = bscText, let weights = weight {
            
            self.bcScoreLbl.text = "The Body condition score is: \(bCScore)"
            self.weightLbl.text = weights
            self.petName.text = pet.name
            petImage.imageUrl = pet.imageURL
        } else {
            self.bcScoreLbl.text = ""
            self.weightLbl.text = ""
            self.petName.text = ""

        }
        
        self.navigationItem.title = "Recommendations"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closedPress(sender:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBtnPressed(sender:)))

        updateTextViewBasedOnWeightAndOtherUI()
        

    }
    
    
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
    
    func doneBtnPressed(sender: UIBarButtonItem) {

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
                if error == nil, let _ = pet {
                    let notificationName = Notification.Name("BcScore")
                    NotificationCenter.default.post(name: notificationName, object: nil)

                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    self.alert(title: "", msg: "An error occured, please try again", type: .red, disableTime: 3, handler: nil)
                }
            })
            
        }
        
    }
    
    
    func updateTextViewBasedOnWeightAndOtherUI() {
        guard let weightt = weight else {return}
        self.weightLbl.textColor = obseAndVeryThinColor

        if weightt == "Very thin" {
            self.reccomTextView.text = """
            Recommendations
            
            Consult a veterinary surgeon
            """
            
            self.reccomTextView.textColor = UIColor.gray

            reccomTextView.border(color: .primary, width: 0.7)

        } else if weightt == "Underweight" {
            
            self.weightLbl.textColor = threeColor

            
            self.reccomTextView.text = """
            Recommendations
            
            \u{2022}  Consult your vet to see if you are underfeeding your pet or there are underlying health issues
            
            \u{2022}  It is normal for certain breeds such as sight hounds to have body condition score of 2
            """
            
            self.reccomTextView.textColor = UIColor.gray
            reccomTextView.border(color: .primary, width: 0.7)


        } else if weightt == "Ideal" {
            self.weightLbl.textColor = idealColor

            
            self.reccomTextView.text = """
            Recommendations:
            
            WELL DONE
            
            Keep doing what you are doing
            """
            
            self.reccomTextView.textColor = UIColor.gray
            reccomTextView.border(color: .primary, width: 0.7)
            



        }else if weightt == "Overweight" {
            self.weightLbl.textColor = threeColor

            self.reccomTextView.text = """
            Recommendations:
            
            \u{2022}  Look for diet dog foods
            
            \u{2022}  Cut back on the food amounts your dog is eating
            
            \u{2022}  Introduce exercise gradually if your dog is not fit. Start with a brisk walk of 10 to 15 minutes two or three times a day.It takes a few months for a dog to lose noticeable weight so don't try to rush it too much.
            """
            
            self.reccomTextView.textColor = UIColor.gray
            reccomTextView.border(color: .primary, width: 0.7)


        }else if weightt == "Obese" {
            self.weightLbl.textColor = obseAndVeryThinColor

            self.reccomTextView.text = """
            Recommendations:
            
            \u{2022}  This can cause serious health issues such as diabetes, high blood pressure, joint problems and heart related issues
            
            \u{2022}  Consult your vet on how best to lose the weight by a combination of exercise and diet foods
            """
            
            self.reccomTextView.textColor = UIColor.gray
            reccomTextView.border(color: .primary, width: 0.7)
            
        }
        
    }
    
    func closedPress(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
