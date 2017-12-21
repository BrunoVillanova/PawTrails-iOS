//
//  PTSignalView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 23/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTSignalView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let signalFullIcon = UIImage(named: "SignalFull")
    let imageView = UIImageView(frame: CGRect(x: 0, y:0, width: 20, height: 10))

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
        imageView.image = signalFullIcon
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.frame = CGRect(x: 0, y:0, width: signalFullIcon!.size.width, height: signalFullIcon!.size.height)
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(imageView)
    }
}
