//
//  LaunchViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 16/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import GSMessages

class LaunchViewController: UIViewController {

    @IBOutlet weak var launchImageView: UIImageView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        
        configureUIPreferences()
        
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
        
        
        if DataManager.instance.isAuthenticated() {
            // Workaround: calling this method to validate token and check account verification status
            self.showLoadingView()
            APIRepository.instance.loadPets { (error, pets) in

                self.hideLoadingView()
                
                if let error = error {
                    
                    
                    var showVerification = false
                    
                    if let errorCode = error.errorCode, errorCode == .AccountNeedsVerification {
                        showVerification = true
                    }
                    
                    self.appDelegate.loadAuthenticationScreen(showVerification)
                    self.appDelegate.showOnboardingIfNeeded(false)
                    
                    if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, let errorCode = error.errorCode {
                        rootViewController.showMessage(errorCode.description, type: .error)
                    }
                    
                } else  {
                    self.appDelegate.loadHomeScreen(animated: true)
                    self.appDelegate.showOnboardingIfNeeded(false)
                }
            }
            
        } else {
            self.appDelegate.loadAuthenticationScreen()
            self.appDelegate.showOnboardingIfNeeded(false)
        }
    }
    
    private func configureUIPreferences() {
        GSMessage.successBackgroundColor = UIColor(red: 81.0/255, green: 222.0/255, blue: 147.0/255,  alpha: 0.95)
        GSMessage.errorBackgroundColor = PTConstants.colors.newRed
        
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().barTintColor = UIColor.secondary
        UINavigationBar.appearance().tintColor = PTConstants.colors.newRed
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Medium", size: 16)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        UITabBar.appearance().tintColor = UIColor.primary
        UITableViewCell.appearance().tintColor = PTConstants.colors.newRed
        UISegmentedControl.appearance().tintColor = PTConstants.colors.newRed
        UIActivityIndicatorView.appearance().color = PTConstants.colors.newRed
        
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 14)!], for: .normal)
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 14)!], for: .selected)
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Montserrat-Regular", size: 14)!], for: .highlighted)
    }
}
