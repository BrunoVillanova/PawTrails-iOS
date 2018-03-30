//
//  OnboardingStepViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 03/27/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import BWWalkthrough

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
            
            let attributedString = NSMutableAttributedString(string: onboardingStep.text)
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 6

            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            textLabel.attributedText = attributedString;
            
            titleLabel.text = onboardingStep.title
            imageView.image = UIImage(named: onboardingStep.imageName)
        }
    }
    
    fileprivate func configureLayout() {
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            titleLabelTopConstraint.constant = 24
            textLabelToBottomConstraint.constant = 100
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            titleLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
            textLabel.font = UIFont(name: "Montserrat-Regular", size: 12)
        } else if UIDevice.current.screenType == .iPhoneX {
            titleLabelTopConstraint.constant = 70
            textLabelToBottomConstraint.constant = 180
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

extension OnboardingStepViewController: BWWalkthroughPage {
    
    func walkthroughDidScroll(to: CGFloat, offset: CGFloat) {
        var tr = CATransform3DIdentity
        tr.m34 = -1/500.0
        
        titleLabel?.layer.transform = CATransform3DRotate(tr, CGFloat(Double.pi) * (1.0 - offset), 1, 1, 1)
        textLabel?.layer.transform = CATransform3DRotate(tr, CGFloat(Double.pi) * (1.0 - offset), 1, 1, 1)
        
        var tmpOffset = offset
        if(tmpOffset > 1.0){
            tmpOffset = 1.0 + (1.0 - tmpOffset)
        }
        imageView?.layer.transform = CATransform3DTranslate(tr, 0 , (1.0 - tmpOffset) * 200, 0)
    }
}
