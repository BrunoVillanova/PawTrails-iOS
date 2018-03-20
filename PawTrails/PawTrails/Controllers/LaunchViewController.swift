//
//  LaunchViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 16/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    fileprivate func initialize() {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if DataManager.instance.isAuthenticated() {
            // Workaround: calling this method to validate token and check account verification status

            APIRepository.instance.loadPets { (error, pets) in

                if let error = error, error.httpCode == 401 {
                    
                    appDelegate.loadAuthenticationScreen()
    
                    if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, let errorCode = error.errorCode {
                        rootViewController.showMessage(errorCode.description, type: .error)
                    }
                    
                } else  {
                    appDelegate.loadHomeScreen(animated: true)
                }
            }
            
        } else {
            appDelegate.loadAuthenticationScreen()
        }
    }
}
