//
//  LeftMenuContentViewController.swift
//  PawTrails
//
//  Created by Bruno Villanova on 09/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class LeftMenuContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initialize() {
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

}

class PTMenuBackgroundView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var backgroundImage: UIImage?
    let backgroundLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        self.layer.insertSublayer(backgroundLayer, at: 0)
        
        var imageName: String?
        
        switch UIDevice.current.screenType {
        case .iPhone4_4S:
            imageName = "MenuBackgroundImage-iPhone4S"
        case .iPhones_5_5s_5c_SE:
            imageName = "MenuBackgroundImage-iPhoneSE"
        case .iPhones_6_6s_7_8:
            imageName = "MenuBackgroundImage-iPhone8"
        case .iPhones_6Plus_6sPlus_7Plus_8Plus:
            imageName = "MenuBackgroundImage-iPhone8Plus"
        case .iPhoneX:
            imageName = "MenuBackgroundImage-iPhoneX"
        default:
            break
        }
        
        if let imageName = imageName, let image = UIImage(named: imageName) {
            backgroundImage = image
            backgroundLayer.contents = backgroundImage?.cgImage
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = self.bounds
    }
}
