//
//  PetBirthdayAndWeightViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 02/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

class PetBirthdayAndWeightViewController: PetWizardStepViewController {

    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var weightSliderContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func nextButtonVisible() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        let ruler = PTRulerSlider(frame: CGRect(x: 0, y: 300, width: UIScreen.main.bounds.width, height: 24), scrollP:61,scrollQ:8600, scaleP: 0, scaleQ: 100)
        ruler.delegate = self
        weightSliderContainerView.addSubview(ruler)
        
        ruler.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(80)
        }
    }

}

extension PetBirthdayAndWeightViewController: SliderDelegate {
    func sliderDidScroll(value: Double) {
        self.pet!.weight = value
    }
}
