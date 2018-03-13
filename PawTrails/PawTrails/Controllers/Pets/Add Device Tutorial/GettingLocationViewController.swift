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
        self.navigationController?.navigationBar.topItem?.title = " "
        
        pinImage.layer.superlayer?.insertSublayer(pulsator, below: pinImage.layer)
        pulsator.start()
        pulsator.backgroundColor = UIColor.white.cgColor
        pulsator.numPulse = 6
        pulsator.radius = 350
        pulsator.animationDuration = 8
        
        if isBetaDemo {
            //For the demo, close this page after 2 sec.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.pulsator.stop()
                self.goToSuccessViewController()
            }
            
        }
        else {
            if let pet = pet {
                DataManager.instance.lastPetDeviceData(pet, gpsMode: .live)
                    .subscribe(onNext: { (petDeviceData) in
                        if let point = petDeviceData?.deviceData.point, point.latitude != 0 && point.longitude != 0 {
                            DispatchQueue.main.async {
                                self.pulsator.stop()
                                self.goToSuccessViewController()
                            }
                        }
                        else {
                            print("location unavailable")
                        }
                    }).disposed(by: disposeBag)
            }
        }
        
    }
    
    fileprivate func goToSuccessViewController() {
        let successViewController = storyboard?.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
        self.navigationController?.pushViewController(successViewController, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = pinImage.layer.position
    }
}
