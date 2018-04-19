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

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        
     tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
    }
    
    
    func configureNavBar() {
        
        self.title = "About PawTrails"
        let attributes = [NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 18)!,NSForegroundColorAttributeName: PTConstants.colors.darkGray]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = PTConstants.colors.darkGray
    }
    
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Private methods

     fileprivate func visitUsPressed() {
        
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
    
     fileprivate func contactUsBtnPressed() {
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
    
    
    
    
    
    
     fileprivate func facebookBtnPressed() {
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
    
     fileprivate func instagramBtnPressed() {
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
    
    fileprivate func youtubeBtnPressed() {
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
     fileprivate func rateUsOnBtnPressed() {
        
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

extension AboutPawTrails: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AboutUsCell{
            
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Visit PawTrails Website"
                cell.iconImage.image = UIImage(named:"WechatIMG135")
            case 1:
                cell.titleLabel.text = "Like us on Facebook"
                cell.iconImage.image = UIImage(named:"facebook")
            case 2:
                cell.titleLabel.text = "Follow us on Instagram"
                cell.iconImage.image = UIImage(named:"instagram")
            case 3:
                cell.titleLabel.text = "Watch us on Youtube"
                cell.iconImage.image = UIImage(named:"youtube")
            case 4:
                cell.titleLabel.text = "Rate us on App Store"
                cell.iconImage.image = UIImage(named:"app-store")
            default:
                break
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nothing", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            visitUsPressed()
        case 1:
            facebookBtnPressed()
        case 2:
            instagramBtnPressed()
        case 3:
            youtubeBtnPressed()
        case 4:
            rateUsOnBtnPressed()
        default:
            break
        }
    }
    
}

class AboutUsCell : UITableViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
}
