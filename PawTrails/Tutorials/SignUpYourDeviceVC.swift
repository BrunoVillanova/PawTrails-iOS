//
//  SignUpYourDeviceVC.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class SignUpYourDeviceVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "tutorialShowen")
    }


    
    @IBAction func continou(_ sender: Any) {
    }
    
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        let root = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        root.selectedIndex = 0
        self.present(root, animated: true, completion: nil)
    }

}
