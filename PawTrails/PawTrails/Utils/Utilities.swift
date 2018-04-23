//
//  Utilities.swift
//  PawTrails
//
//  Created by Abhijith on 18/04/2018.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import Foundation

class Utilities {
    
    
    class func showComingSoonAlert(_ functionTitle: String) {
        let title = "Coming Soon"
        let infoText = "\(functionTitle) function is currently under construction. We are working hard on the new feature, please check back later."
        self.showAlert(title, infoText: infoText, titleBarStyle: .yellow)
    }
    
    class func showAlert(_ title: String?, infoText: String?, titleBarStyle: AlertTitleBarStyle? = .red) {
        let alertView = PTAlertViewController(title, infoText: infoText, buttonTypes: [AlertButtontType.ok], titleBarStyle: titleBarStyle, alertResult: {alert, result in
            alert.dismiss(animated: true, completion: nil)
        })
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(alertView, animated: true, completion: nil)
        }
    }
    
}
