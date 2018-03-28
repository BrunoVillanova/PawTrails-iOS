//
//  OnboardingStepViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 03/27/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class OnboardingStepViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    var onboardingStep: OnboardingStep?
    
    @IBOutlet weak var textLabelToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(_ onboardingStep: OnboardingStep) {
        self.onboardingStep = onboardingStep
    
    }
    
    fileprivate func initialize() {
        configureLayout()
        if let onboardingStep = onboardingStep {
            titleLabel.text = onboardingStep.title
            textLabel.text = onboardingStep.text
            imageView.image = UIImage(named: onboardingStep.imageName)
        }
    }
    
    fileprivate func configureLayout() {
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            titleLabelTopConstraint.constant = 16
            textLabelToBottomConstraint.constant = 100
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
        }
    }
}


struct OnboardingStep {
    var title: String
    var text: String
    var imageName: String
}

extension OnboardingStep {
    init(_ title: String, text: String, imageName: String) {
        self.title = title
        self.text = text
        self.imageName = imageName
    }
}
