//
//  PetProfileViewController.swift
//  Snout
//
//  Created by Marc Perello on 24/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PetProfileViewController: UIViewController {

    @IBOutlet weak var blurView: UIVisualEffectView!
    override func viewDidLoad() {
        self.blurView.round(radius: 20)
        super.viewDidLoad()
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
