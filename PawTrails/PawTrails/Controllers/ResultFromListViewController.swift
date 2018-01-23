//
//  ResultFromListViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 27/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class ResultFromListViewController: UIViewController {
    
    
    var pet: Pet!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bcScoreLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var petProfile: UiimageViewWithMask!
    @IBOutlet weak var petName: UILabel!
    
    
    let idealColor = UIColor(red: 112/255, green: 163/255, blue: 8/255, alpha: 1)
    let obseAndVeryThinColor = UIColor(red: 213/255, green: 0/255, blue: 0/255, alpha: 1)
    let threeColor = UIColor(red: 247/255, green: 101/255, blue: 0/255, alpha: 1)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.border(color: UIColor.primary, width: 0.7)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closedPress(sender:)))
        
        self.navigationItem.title = "Recommendations"
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        guard let myPet = self.pet else {return}
        
        self.petName.text = myPet.name
        self.bcScoreLbl.text = "The body condition score is \(myPet.bcScore)"
        
        if let imageData = pet.image as Data? {
            petProfile.image = UIImage(data: imageData)
        }else{
            petProfile.image = nil
        }
        
        if myPet.bcScore == 1 {
            self.weightLbl.text = "Very thin"
            self.weightLbl.textColor = obseAndVeryThinColor
            
            self.textView.text = """
            Consult a veterinary surgeon
            """
            
            self.textView.textColor = UIColor.gray
            
        } else if myPet.bcScore == 2 {
            self.weightLbl.text = "Under weight"
            self.weightLbl.textColor = threeColor

            
            self.textView.text = """
            \u{2022}  Consult your vet to see if you are underfeeding your pet or there are underlying health issues
            
            \u{2022}  It is normal for certain breeds such as sight hounds to have body condition score of 2
            """
            
            self.textView.textColor = UIColor.gray

            
        }else if myPet.bcScore == 3 {
            self.weightLbl.text = "Ideal"
            self.weightLbl.textColor = idealColor
            
            
            self.textView.text = """
            WELL DONE
            
            Keep doing what you are doing
            """
            
            self.textView.textColor = UIColor.gray
            

            
        }else if myPet.bcScore == 4 {
            self.weightLbl.text = "Overweight"
            self.weightLbl.textColor = threeColor
            
            self.textView.text = """
            \u{2022}  Look for diet dog foods
            
            \u{2022}  Cut back on the food amounts your dog is eating
            
            \u{2022}  Introduce exercise gradually if your dog is not fit
            
            \u{2022}  It takes a few months for a dog to lose noticeable weight so don't try to rush it too much
            """
            
            self.textView.textColor = UIColor.gray


        }else if myPet.bcScore == 5 {
            self.weightLbl.text = "Obese"
            self.weightLbl.textColor = obseAndVeryThinColor

            self.textView.text = """
            \u{2022}  This can cause serious health issues such as diabetes, high blood pressure, joint problems and heart related issues
            
            \u{2022}  Consult your vet on how best to lose the weight by a combination of exercise and diet foods
            """
            
            self.textView.textColor = UIColor.gray
        }
    }
    
    func closedPress(sender: UIBarButtonItem) {
       _ = navigationController?.popViewController(animated: true)
        
    }

}
