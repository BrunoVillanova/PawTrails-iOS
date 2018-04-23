//
//  BCSInitialViewController.swift
//  PawTrails
//
//  Created by Abhijith on 17/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class BCSInitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configureNavigationBar() {
        
        if let navigationController = self.navigationController as? PTNavigationViewController {
            navigationController.showNavigationBarDropShadow = true
        }
    }

    fileprivate func initialize() {
        configureNavigationBar()
    }

}
