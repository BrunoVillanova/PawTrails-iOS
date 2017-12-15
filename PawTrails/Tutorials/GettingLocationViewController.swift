//
//  GettingLocationViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 15/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import Pulsator

class GettingLocationViewController: UIViewController {
    
    // Here you connect to socket.Io and get this pet immediate location
    
    
    
    let kMaxRadius: CGFloat = 500
    let kMaxDuration: TimeInterval = 10
    
    let pulsator = Pulsator()

    @IBOutlet weak var pinImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pinImage.layer.superlayer?.insertSublayer(pulsator, below: pinImage.layer)
        pulsator.start()
        pulsator.backgroundColor = UIColor.white.cgColor
        pulsator.numPulse = 6
        pulsator.radius = 350
        pulsator.animationDuration = 8

    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = pinImage.layer.position
        
    }
   
}
