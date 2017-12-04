//
//  PTBalloonImageView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 03/12/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTBalloonImageView: UIView {

    let pictureBaseSize : CGFloat = 13.0
    var borderImageView: UIImageView?
    var pictureImageView: UIImageView?
    var image: UIImage? {
        didSet {
            pictureImageView?.image = image
        }
    }
    
    
    override func awakeFromNib() {
        initialize()
    }
    
    fileprivate func initialize() {
        self.backgroundColor = UIColor.clear
        borderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        borderImageView!.image = #imageLiteral(resourceName: "userProfileMask-1x-png");
        self.addSubview(borderImageView!)
        
        pictureImageView = UIImageView()
        var pictureFrame = CGRect()
        pictureFrame.size.height = self.frame.size.height - pictureBaseSize
        pictureFrame.size.width = pictureFrame.size.height
        pictureImageView?.frame = pictureFrame
        pictureImageView?.center = borderImageView!.center
        pictureImageView?.image = #imageLiteral(resourceName: "PetPlaceholderImage")
        pictureFrame = pictureImageView!.frame
        pictureFrame.origin.y = pictureFrame.origin.y - 2
        pictureImageView?.frame = pictureFrame
        pictureImageView?.circle()
        pictureImageView?.backgroundColor = UIColor.clear
        self.addSubview(pictureImageView!)
        self.bringSubview(toFront: pictureImageView!)
    }
}
