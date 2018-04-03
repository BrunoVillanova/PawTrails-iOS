//
//  PetWizardFInalStepViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 04/02/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import Pulsator
import SnapKit
import RxSwift

class PetWizardFinalStepViewController: PetWizardStepViewController {

    @IBOutlet weak var gettingLocationImageContainer: UIView!
    @IBOutlet weak var placemarkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var gettingLocationView: UIView!
    @IBOutlet weak var timeoutView: UIView!
    @IBOutlet weak var completedView: UIView!
    @IBOutlet weak var retryGetLocationButton: UIButton!
    @IBOutlet weak var getStartedButton: UIButton!
    
    let pulsator = Pulsator()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGettingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()

        if let superLayer = pulsator.superlayer, let hiperLayer = superLayer.superlayer {
            pulsator.radius = (hiperLayer.bounds.height / 2.0) - 30
            pulsator.position = CGPoint(x: superLayer.bounds.width / 2.0, y: (superLayer.bounds.height / 2.0)-6)
        }
    }
    
    fileprivate func initialize() {
        placemarkImageView.layer.addSublayer(pulsator)
        pulsator.backgroundColor = PTConstants.colors.newRed.cgColor
        pulsator.numPulse = 6
        pulsator.animationDuration = 8
        retryGetLocationButton.circle()
    }
    
    
    fileprivate func startGettingLocation() {
        
        if self.gettingLocationView.isHidden {
            self.gettingLocationView.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.gettingLocationView.alpha = 1
                self.timeoutView.alpha = 0
            }) { (finished) in
                if finished {
                    self.timeoutView.isHidden = true
                    self.startGetPosition()
                }
            }
        } else {
            self.startGetPosition()
        }
    }
    
    fileprivate func startGetPosition() {
        
        if let pet = pet {
            
            pulsator.start()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                self.pulsator.stop()
                self.timeoutGettingLocation()
            }
            
            DataManager.instance.lastPetDeviceData(pet, gpsMode: .live)
                .subscribe(onNext: { (petDeviceData) in
                    if let point = petDeviceData?.deviceData.point, point.latitude != 0 && point.longitude != 0 {
                        DispatchQueue.main.async {
                            self.pulsator.stop()
                            self.showSuccessView()
                        }
                    }
                }).disposed(by: disposeBag)
        }
    }
    
    fileprivate func timeoutGettingLocation() {
        
        self.timeoutView.alpha = 0
        self.timeoutView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.gettingLocationView.alpha = 0
            self.timeoutView.alpha = 1
        }) { (finished) in
            if finished {
                self.gettingLocationView.isHidden = true
            }
        }
    }
    
    fileprivate func showSuccessView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.gettingLocationView.alpha = 0
            self.completedView.alpha = 1
        }) { (finished) in
            if finished {
                self.gettingLocationView.isHidden = true
            }
        }
    }
    
    @IBAction func retryGetLocationButtonTapped(_ sender: Any) {
        startGettingLocation()
    }
    
    @IBAction func getStartedButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
