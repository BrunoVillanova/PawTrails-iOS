//
//  SetUpYourGoalController.swift
//  PawTrails
//
//  Created by Marc Perello on 12/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SetUpYourGoalController: UIViewController {

    var pet: Pet!
    var isOwner: Bool!
    var petUser: PetUser!

    @IBOutlet weak var restToDefult: UIButton!
    @IBOutlet weak var NormalGoalSlider: UISlider!
    @IBOutlet weak var restingGoalSlider: UISlider!
    
    
    var adventureSlidelabel: UILabel?
    var playingSliderLabel: UILabel?
    var nomalSliderLabel: UILabel?
    var restingSliderLabel: UILabel?
    
    var nomralSliderValue:Float = 0.0
    var playingSliderValue:Float = 0.0
    var restingSliderValue: Float = 0.0
    var adventureSliderValue: Float = 0.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restToDefult.round()
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        
        let image = UIImage(named: "SliderBtn")?.scaleToSize(newSize: CGSize(width: 70, height: 40))

        NormalGoalSlider.setThumbImage(image, for: .normal)
        restingGoalSlider.setThumbImage(image, for: .normal)
        
        let restingColors = UIColor(red: 153/255, green: 202/255, blue: 186/255, alpha: 1)
        let normalColors = UIColor(red: 211/255, green: 100/255, blue: 59/255, alpha: 1)
        
        if let handleView = restingGoalSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            handleView.addSubview(label)
            label.textColor = restingColors

            
            self.restingSliderLabel = label
            self.restingSliderLabel?.text = "\(Int(restingSliderValue)) Km"

        }
        
        
        if let handleView = NormalGoalSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.textColor = normalColors
            handleView.addSubview(label)
            self.nomalSliderLabel = label
            
            self.nomalSliderLabel?.text = "\(Int(nomralSliderValue)) hrs"

        }

    }
    

    
    @IBAction func restingAction(_ sender: UISlider) {
        if sender.maximumValue == 0 {
            restingSliderValue = sender.value
        } else {
            restingSliderValue = sender.value
            restingSliderLabel?.text = "\(Int(sender.value)) Km"
        }
    }
    
    
    @IBAction func nomalAction(_ sender: UISlider) {
        nomralSliderValue = sender.value
        nomalSliderLabel?.text = "\(Int(sender.value)) hrs"
    }
   
    @IBAction func SaveBtnPressed(_ sender: UIBarButtonItem) {
    }
    

    @IBAction func restToDefultBtnPressed(_ sender: Any) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Default Time Goal", message: "The time goal default is recommended by Joe Keane , veterinary surgeon. These guidelines should be followed if you dog is the ideal weight on the Body Condition Score (BCS).", preferredStyle: .alert)
        
        // Create the actions
        let setTimeGoal = UIAlertAction(title: "Set TIME GOAL", style: UIAlertActionStyle.default) {
            UIAlertAction in
            
            // do something here
        }
        
        
        let goToBsc = UIAlertAction(title: "GO TO BCS", style: UIAlertActionStyle.default) {
            UIAlertAction in
            if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
                tabViewController.selectedIndex = 2
                self.present(tabViewController, animated: true, completion: nil)
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(setTimeGoal)
        alertController.addAction(goToBsc)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.primary
        
    }
    
}


extension UIImage {
    
    func scaleToSize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newImage
    }
}
