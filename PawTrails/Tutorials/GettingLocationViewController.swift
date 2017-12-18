//
//  GettingLocationViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 15/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import Pulsator
import RxSwift

class GettingLocationViewController: UIViewController {
    
    // Here you connect to socket.Io and get this pet immediate location
    
    var pet: Pet?
    
    let kMaxRadius: CGFloat = 500
    let kMaxDuration: TimeInterval = 10
    
    let pulsator = Pulsator()
    
    private let disposeBag = DisposeBag()


    @IBOutlet weak var pinImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pinImage.layer.superlayer?.insertSublayer(pulsator, below: pinImage.layer)
        pulsator.start()
        pulsator.backgroundColor = UIColor.white.cgColor
        pulsator.numPulse = 6
        pulsator.radius = 350
        pulsator.animationDuration = 8
        
//        if let pet = pet {
//            DataManager.instance.lastPetDeviceData(pet).subscribe(onNext: { (petDeviceData) in
//                if let petDeviceData = petDeviceData {
//                    print(petDeviceData)
//                }
//                
//            }).disposed(by: disposeBag)
//        }
        
        

    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = pinImage.layer.position
        
    }
   
}
