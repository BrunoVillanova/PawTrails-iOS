//
//  SetUpYourGoalController.swift
//  PawTrails
//
//  Created by Marc Perello on 12/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SetUpYourGoalController: UIViewController {

    var petId: Int!
    var isOwner: Bool!
    
    @IBOutlet weak var adventureSlider: UISlider!
    @IBOutlet weak var playngSlider: UISlider!
    @IBOutlet weak var NormalGoalSlider: UISlider!
    @IBOutlet weak var restToDefult: UIButton!
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
       
        restToDefult.backgroundColor = UIColor.primary
        restToDefult.fullyroundedCorner()
        
        self.popUpDestructive(title: "Note", msg: "The value of resting, normal and playing goals must be 24 hours", cancelHandler: nil) { (proceed) in
            
        }
        
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        
        let image = UIImage(named: "SliderBtn")?.scaleToSize(newSize: CGSize(width: 70, height: 40))
        
        adventureSlider.setThumbImage(image, for: .normal)
        playngSlider.setThumbImage(image, for: .normal)
        NormalGoalSlider.setThumbImage(image, for: .normal)
        restingGoalSlider.setThumbImage(image, for: .normal)
        
        let restingColors = UIColor(red: 153/255, green: 202/255, blue: 186/255, alpha: 1)
        let normalColors = UIColor(red: 211/255, green: 100/255, blue: 59/255, alpha: 1)
        let playingColors = UIColor(red: 67/255, green: 62/255, blue: 54/255, alpha: 1)
        let adventureColor = UIColor(red: 108/255, green: 176/255, blue: 255/255, alpha: 1)


    
        
        if let handleView = adventureSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.textColor = adventureColor

            handleView.addSubview(label)
            self.adventureSlidelabel = label
//            let value = self.adventureSlider.value
            self.adventureSlidelabel?.text = "\(adventureSliderValue)"
        }
        
        
        
        
        if let handleView = playngSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.textColor = playingColors


            handleView.addSubview(label)
            
            self.playingSliderLabel = label
            let value = self.playngSlider.value
            self.playingSliderLabel?.text = "\(value)"

            
        }
        
        
        if let handleView = restingGoalSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            handleView.addSubview(label)
            label.textColor = restingColors

            
            self.restingSliderLabel = label
//            let value = self.restingGoalSlider.value
            self.restingSliderLabel?.text = "\(restingSliderValue)"
        }
        
        
        if let handleView = NormalGoalSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.textColor = normalColors


            handleView.addSubview(label)
            self.nomalSliderLabel = label
            self.nomalSliderLabel?.text = "\(nomralSliderValue)"
        }

    }
    
    
    
    
    
    
    
    @IBAction func adventureAction(_ sender: UISlider) {
        
        adventureSliderValue = sender.value
        adventureSlidelabel?.text = "\(Int(sender.value)) H"
        
      
    }
    
    @IBAction func playingAction(_ sender: UISlider) {
        
        sender.maximumValue = 24 - (restingSliderValue + nomralSliderValue)

        playingSliderValue = sender.value
        playingSliderLabel?.text = "\(Int(sender.value)) H"



    }
    
    @IBAction func restingAction(_ sender: UISlider) {
        sender.maximumValue = 24 - (nomralSliderValue + playingSliderValue)
        
        
        if sender.maximumValue == 0 {
            restingSliderValue = sender.value
        } else {
            restingSliderValue = sender.value
            restingSliderLabel?.text = "\(Int(sender.value)) H"
        }
        

    }
    
    
    @IBAction func nomalAction(_ sender: UISlider) {
        sender.maximumValue = 24 - (restingSliderValue + playingSliderValue)
        nomralSliderValue = sender.value
        nomalSliderLabel?.text = "\(Int(sender.value)) H"


    }
   
    @IBAction func SaveBtnPressed(_ sender: UIBarButtonItem) {
    }
    
    
    @IBAction func restButtonPressed(_ sender: Any) {
        self.adventureSlider.setValue(0.0, animated: true)
        self.playngSlider.setValue(0.0, animated: true)
        self.restingGoalSlider.setValue(0.0, animated: true)
        self.NormalGoalSlider.setValue(0.0, animated: true)
        
        
        adventureSlidelabel?.text = "\(Int(adventureSlider.value)) H"
        playingSliderLabel?.text = "\(Int(playngSlider.value)) H"
        restingSliderLabel?.text = "\(Int(restingGoalSlider.value)) H"
        nomalSliderLabel?.text = "\(Int(NormalGoalSlider.value)) H"


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
