//
//  PTBubbleView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 17/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTBubbleView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        PawTrailsStyleKit.drawBubble(frame: self.bounds)
    }

}
