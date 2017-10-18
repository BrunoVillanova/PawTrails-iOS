//
//  RecommandationController.swift
//  PawTrails
//
//  Created by Marc Perello on 18/10/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class RecommandationController: UIViewController {

    @IBOutlet weak var startnowBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        startnowBtn.backgroundColor = UIColor.primary
        startnowBtn.layer.cornerRadius = 25
        startnowBtn.clipsToBounds = true
    }

   
}
