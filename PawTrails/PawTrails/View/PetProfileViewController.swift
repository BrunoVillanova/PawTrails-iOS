//
//  PetProfileViewController.swift
//  Snout
//
//  Created by Marc Perello on 24/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetProfileViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var pet:_pet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.blurView.round(radius: 20)
        self.imageView.round()
        if pet != nil {
            self.firstLabel.text = pet?.name
            self.secondLabel.text = pet!.tracking ? "Tracking ON" : "Tracking OFF"
//            self.imageView.backgroundColor = pet?.color
//            self.thirdLabel.text = "Last Position:\n\(pet!.location?.coordinate.latitude) / \(pet!.location?.coordinate.longitude)"
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
