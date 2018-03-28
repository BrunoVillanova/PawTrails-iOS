//
//  OnboardingViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 03/27/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import BWWalkthrough

class OnboardingViewController: BWWalkthroughViewController {

    @IBOutlet weak var commonButton: UIButton!
    @IBOutlet weak var lastStepOnlyButton: UIButton!
    @IBOutlet weak var lastStepButtonAuxiliarView: UIView!
    @IBOutlet weak var commonButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastStepButtonAuxiliarViewHeightConstraint: NSLayoutConstraint!
    
    
    final let onboardingCompletedUserPreferencesKey = "onboardingCompleted"
    final let controlViewControllerIdentifier = "onboarding"
    final let stepViewControllerIdentifier = "onboardingStep"
    final let onboardingSteps = [
        OnboardingStep(title: "Puts you in control of your pets",
                         text: "PawTrails Smart Collar / Harness always puts you in control of your pets.",
                    imageName: "Onboarding0"),
        OnboardingStep(title: "Show up Your Pet’s Location",
                         text: "Live tracking your pet’s current location, no more lost again.",
                    imageName: "Onboarding1"),
        OnboardingStep(title: "Activity Tracking with Monitor",
                         text: "Track your pet’s 24/7 activity with PawTrails Smart Collar / Harness.",
                    imageName: "Onboarding2"),
        OnboardingStep(title: "Healthier, Happier Pets",
                         text: "Manage your best friend’s care beyond health records.",
                    imageName: "Onboarding3"),
    ]
    
    var onboardingStoryboard: UIStoryboard {
        get {
            return UIStoryboard(name: "Onboarding", bundle: nil)
        }
    }
    
    static var onboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "onboardingCompleted")
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: "onboardingCompleted")
            userDefaults.synchronize()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
        
        self.delegate = self
        
        configureLayout()
        
        for step in onboardingSteps {
            let stepViewController = onboardingStoryboard.instantiateViewController(withIdentifier: stepViewControllerIdentifier) as! OnboardingStepViewController
            stepViewController.configure(step)
            self.add(viewController:stepViewController)
        }
    }
    
    fileprivate func makeViewVisibleAnimated(_ view: UIView) {
        guard view.isHidden || view.alpha == 0 else {
            return
        }
    
        view.alpha = 0
        view.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        }
    }
    
    fileprivate func configureLayout() {
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            commonButtonBottomConstraint.constant = 22
        } else if UIDevice.current.screenType == .iPhoneX {
            lastStepButtonAuxiliarViewHeightConstraint.constant = 44
        }
    }
    
    @IBAction func lastStepOnlyButtonTapped(_ sender: Any) {
        OnboardingViewController.onboardingCompleted = true
        self.dismiss(animated: true, completion: nil)
    }
}

extension OnboardingViewController: BWWalkthroughViewControllerDelegate {
    func walkthroughPageDidChange(_ pageNumber: Int) {
        let isLastPage = pageNumber == onboardingSteps.count-1
        if isLastPage {
            OnboardingViewController.onboardingCompleted = isLastPage
            makeViewVisibleAnimated(lastStepOnlyButton)
            makeViewVisibleAnimated(lastStepButtonAuxiliarView)
        }
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
