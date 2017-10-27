//
//  PTBatteryView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 18/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTBatteryView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let batteryIcon = UIImage(named: "Battery")
    let batteryLowIcon = UIImage(named: "BatteryLow")
    let imageView = UIImageView(frame: CGRect(x: 0, y:0, width: 20, height: 10))
    let batteryFillView = UIView(frame: CGRect(x: 0, y:0, width: 20, height: 10))
    let batteryColor = UIColor(red: 105.0/255.0, green: 194.0/255.0, blue: 88.0/255.0, alpha: 1)
    let batteryLowColor = UIColor(red: 240.0/255.0, green: 82.0/255.0, blue: 40.0/255.0, alpha: 1)
    var batteryFillWidthProportion : Float = 1.0
    var firstView = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        
        self.backgroundColor = UIColor.clear
        
        // Create the imageView with the battery image and add it to the view
        imageView.image = batteryIcon
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.frame = CGRect(x: 0, y:0, width: self.frame.width, height: self.frame.height)
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(imageView)
        
        // Create the battery fill view
        batteryFillView.frame = CGRect(x:2, y: 2, width: 0, height: self.frame.size.height-5)
        batteryFillView.backgroundColor = batteryColor
        batteryFillView.alpha = 0
        self.addSubview(batteryFillView)
        
        batteryFillWidthProportion = Float((self.frame.size.width-5) / 100.0)
    }
    
    func setBatteryLevel(_ level: Int) {
        
        let newWidth = CGFloat(batteryFillWidthProportion * Float(level))
        let newBatteryFrame = CGRect(x: batteryFillView.frame.origin.x, y: batteryFillView.frame.origin.y, width: newWidth, height: batteryFillView.frame.size.height)
        
        UIView.animate(withDuration: 2.0) {
            self.batteryFillView.alpha = 1
            self.batteryFillView.frame = newBatteryFrame
            self.batteryFillView.backgroundColor = self.colorForBatteryLevel(level)
        }
    }
    
    fileprivate func colorForBatteryLevel(_ level: Int) -> UIColor {
        var theColor = batteryColor
        
        if level <= 20 {
            theColor = batteryLowColor
        }
        
        return theColor
    }
}
