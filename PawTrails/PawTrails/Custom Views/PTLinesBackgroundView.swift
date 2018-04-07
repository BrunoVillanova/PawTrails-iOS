//
//  PTLinesBackgroundView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 05/04/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit

class PTLinesBackgroundView: UIView {

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
                imageName = "BackgroundImage-iPhone4S"
            case .iPhones_5_5s_5c_SE:
                imageName = "BackgroundImage-iPhoneSE"
            case .iPhones_6_6s_7_8:
                imageName = "BackgroundImage-iPhone8"
            case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                imageName = "BackgroundImage-iPhone8Plus"
            case .iPhoneX:
                imageName = "BackgroundImage-iPhoneX"
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
