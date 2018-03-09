//
//  PTSignalView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 23/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTSignalView: UIView {
    
    let signalFullIcon = UIImage(named: "SignalFull")
    let imageView = UIImageView(frame: CGRect(x: 0, y:0, width: 15, height: 12))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 15, height: 12)
    }
    
    fileprivate func setup() {
        
        self.backgroundColor = UIColor.clear
        
        // Create the imageView with the battery image and add it to the view
        imageView.image = signalFullIcon
        imageView.contentMode = UIViewContentMode.center
        imageView.frame = CGRect(x: 0, y:0, width: signalFullIcon!.size.width, height: signalFullIcon!.size.height)
        self.addSubview(imageView)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        var frame = self.frame
//        frame.size.height = imageView.frame.size.height
//        frame.size.width = imageView.frame.size.width
//        self.frame = frame
//    }
    
    func setSignal(_ level: Int16, animated: Bool = true) {
        //TODO: set images for different levels ANIMATED!!!! =)
        
//        let newWidth = CGFloat(batteryFillWidthProportion * Float(level))
//        let newBatteryFrame = CGRect(x: batteryFillView.frame.origin.x, y: batteryFillView.frame.origin.y, width: newWidth, height: batteryFillView.frame.size.height)
//
//        UIView.animate(withDuration: 2.0) {
//            self.batteryFillView.alpha = 1
//            self.batteryFillView.frame = newBatteryFrame
//            self.batteryFillView.backgroundColor = self.colorForBatteryLevel(level)
//        }
    }
}
