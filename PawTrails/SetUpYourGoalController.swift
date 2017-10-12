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
    
    var slider1:Float = 0.0
    var slider2:Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restToDefult.backgroundColor = UIColor.primary
        restToDefult.fullyroundedCorner()
        
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        
        let image = UIImage(named: "SliderBtn")?.scaleToSize(newSize: CGSize(width: 70, height: 40))
        
        
        
        adventureSlider.setThumbImage(image, for: .normal)
        playngSlider.setThumbImage(image, for: .normal)
        NormalGoalSlider.setThumbImage(image, for: .normal)
        restingGoalSlider.setThumbImage(image, for: .normal)

    
        
        if let handleView = adventureSlider.subviews.last as? UIImageView {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = UIColor.clear
            handleView.addSubview(label)
            
            self.adventureSlidelabel = label
            let value = self.adventureSlider.value
            self.adventureSlidelabel?.text = "\(value)"

        }

    }
    
    
    
    
    
    @IBAction func adventureAction(_ sender: UISlider) {

    }
    
    @IBAction func playingAction(_ sender: UISlider) {

    }
    
    @IBAction func restingAction(_ sender: Any) {
    }
    
    
    @IBAction func nomalAction(_ sender: Any) {
    }
   
    @IBAction func restButtonPressed(_ sender: Any) {
        self.adventureSlidelabel?.text = "fds"

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
