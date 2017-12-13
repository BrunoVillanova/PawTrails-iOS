//
//  AboutPawTrails.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MessageUI

class AboutPawTrails: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    @IBAction func visitUsPressed(_ sender: Any) {
        
        if let urlFromStr = URL(string: "https://www.pawtrails.ie") {
            if UIApplication.shared.canOpenURL(urlFromStr) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlFromStr)
                }
            }
    }
    
    }
    
    @IBAction func contactUsBtnPressed(_ sender: Any) {
        if let urlFromStr = URL(string: "mailto:info@pawtrails.ie") {
            if UIApplication.shared.canOpenURL(urlFromStr) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlFromStr)
                }
            }
        }
        
    }
    
    
    
    
    
    
    @IBAction func facebookBtnPressed(_ sender: Any) {
        if let urlFromStr = URL(string: "fb://profile/1245888162113500") {
            if UIApplication.shared.canOpenURL(urlFromStr) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlFromStr)
                }
            } else if let webURL = URL(string: "https://www.facebook.com/thepawtrails") {
                UIApplication.shared.openURL(webURL)
                
            }
        }
        
        
        
        
    }
    @IBAction func instagramBtnPressed(_ sender: Any) {
        if let urlFromStr = URL(string: "instagram://user?username=pawtrails_smartcollar") {
            if UIApplication.shared.canOpenURL(urlFromStr) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlFromStr)
                }
            } else if let webURL = URL(string: "https://instagram.com/pawtrails_smartcollar") {
                UIApplication.shared.openURL(webURL)

            }
        }
    }
    
    @IBAction func youtubeBtnPressed(_ sender: Any) {
        let youtubeId = "UCbHl4YKaS7UpxMHdgl5TPfQ"
        if let urlFromStr = URL(string: "youtube://\(youtubeId)") {
            if UIApplication.shared.canOpenURL(urlFromStr) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlFromStr)
                }
            } else if let webURL = URL(string: "https://www.youtube.com/channel/UCppa48YXV_sjcE_8rUSm6qQ?disable_polymer=true") {
                UIApplication.shared.openURL(webURL)
                
            }
        }
        
        
    }
    @IBAction func rateUsOnBtnPressed(_ sender: Any) {
        
            if let urlFromStr = URL(string: "https://itunes.apple.com/gb/app/pawtrails/id1321502523?mt=8&ign-mpt=uo%3D2") {
            if UIApplication.shared.canOpenURL(urlFromStr) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlFromStr, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlFromStr)
                }
            } else if let webURL = URL(string: "https://itunes.apple.com/gb/app/pawtrails/id1321502523?mt=8&ign-mpt=uo%3D2") {
                UIApplication.shared.openURL(webURL)
                
            }
        }
    }
}
