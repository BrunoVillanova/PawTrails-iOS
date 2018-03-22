//
//  SignUpYourDeviceVC.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SignUpYourDeviceVC: UIViewController {

    static let tutorialShownUserPreferecesKey = "tutorialShown"
    static let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    fileprivate func initialize() {
        #if !DEBUG
            SignUpYourDeviceVC.userDefaults.set(true, forKey: SignUpYourDeviceVC.tutorialShownUserPreferecesKey)
        #endif
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = [.all]
        configureNavigatonBar()
    }
    
    fileprivate func configureNavigatonBar() {
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.backItem?.title = " "
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    static func tutorialShown() -> Bool {
        if isBetaDemo{
            userDefaults.set(false, forKey: tutorialShownUserPreferecesKey)
        }
        return userDefaults.bool(forKey: tutorialShownUserPreferecesKey)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "StepOneViewController") as? StepOneViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
