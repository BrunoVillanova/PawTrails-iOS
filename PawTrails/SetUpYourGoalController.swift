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
        restingGoalSlider.maximumValue = 50.0
        NormalGoalSlider.maximumValue = 12.0
        
        guard let pet = self.pet else {return}

        APIRepository.instance.getDailyGoals(pet.id) { (error, goal) in
            if error == nil, let goal = goal {
                if goal.distanceGoal > 0, goal.timeGoal > 0 {
                    let totalDistance = Float(goal.distanceGoal / 1000)
                    let totaltime = Float(goal.timeGoal / 60)
                    self.NormalGoalSlider.value = totaltime
                    self.nomralSliderValue = totaltime
                    
                    self.restingSliderLabel?.text = "\(Int(totalDistance)) Km"
                    
                    self.nomalSliderLabel?.text = "\(Int(totaltime)) hrs"

                    self.restingSliderValue = totalDistance
                    self.restingGoalSlider.value = totalDistance
                }
            }
        }
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

        }
        
        
        if let handleView = NormalGoalSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.textColor = normalColors
            handleView.addSubview(label)
            self.nomalSliderLabel = label

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
        // owner only can edit this
        guard let pet = self.pet else {return}
        guard let petName = pet.name else {return}

        
        if pet.isOwner {
            if self.restingSliderValue > 0, self.nomralSliderValue > 0 {
                let distanceGoalInMeter = Int(self.restingSliderValue * 1000)
                let timeGoalInHours = Int(self.nomralSliderValue * 60)
                
                APIRepository.instance.editTripDailyGoal(pet.id, distanceGoal: distanceGoalInMeter, timeGoal: timeGoalInHours, callback: { (error) in
                    if error == nil {
                        self.alert(title: "", msg: "Your request has been proceed", type: .blue, disableTime: 3, handler: nil)
                        if let navController = self.navigationController {
                            navController.popViewController(animated: true)
                        }
                        
                    } else {
                        self.alert(title: "", msg: "Error, Please try again", type: .blue, disableTime: 3, handler: nil)
                    }
                })
            } else {
                self.alert(title: "", msg: "Please change distance and times values", type: .red, disableTime: 3, handler: nil)
            }
        }else {
            self.alert(title: "", msg: "Only \(petName) owner can edit trip goal. ", type: .blue, disableTime: 3, handler: nil)
        }
        
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
