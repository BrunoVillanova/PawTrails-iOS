//
//  LaunchViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 16/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var launchImageView: UIImageView!
    
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
        
        var imageName: String?
        
        switch UIDevice.current.screenType {
            case .iPhone4_4S:
                imageName = "LaunchImage-iPhone4S"
            case .iPhones_5_5s_5c_SE:
                imageName = "LaunchImage-iPhone5"
            case .iPhones_6_6s_7_8:
                imageName = "LaunchImage-iPhone8"
            case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                imageName = "LaunchImage-iPhone8Plus"
            case .iPhoneX:
                imageName = "LaunchImage-iPhoneX"
            default:
                break
        }
        
        if let imageName = imageName, let image = UIImage(named: imageName) {
            launchImageView.image = image
            launchImageView.contentMode = .center
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if DataManager.instance.isAuthenticated() {
            // Workaround: calling this method to validate token and check account verification status
            self.showLoadingView()
            APIRepository.instance.loadPets { (error, pets) in

                self.hideLoadingView()
                
                if let error = error {
                    
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
