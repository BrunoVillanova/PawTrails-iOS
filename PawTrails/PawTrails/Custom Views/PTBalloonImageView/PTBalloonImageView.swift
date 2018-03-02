//
//  PTBalloonImageView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 03/12/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import SDWebImage

class PTBalloonImageView: UIImageView {

    let placeholderImage = UIImage(named: "PetPlaceholderImage")
    
    var borderImageView = UIImageView(frame: CGRect.zero)
    var pictureImageView = UIImageView(frame: CGRect.zero)
    
    override var image: UIImage? {
        get {
            return nil
        }
        set (newImage) {
            if (newImage != pictureImageView.image) {
                if newImage == nil {
                    pictureImageView.image = placeholderImage
                } else {
                    pictureImageView.image = image
                }
                layoutIfNeeded()
            }
        }
    }
    
    var imageUrl: String? {
        didSet {
            if let imageUrl = imageUrl {
                pictureImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: placeholderImage, options: .progressiveDownload, completed: { (image, error, type, url) in
                    
                    if let image = image {
                        self.pictureImageView.image = image
                    } else {
                        self.pictureImageView.image = self.placeholderImage
                    }
                    self.layoutIfNeeded()

                })
            } else {
                pictureImageView.image = #imageLiteral(resourceName: "PetPlaceholderImage")
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        self.backgroundColor = .clear
        
        borderImageView.image = #imageLiteral(resourceName: "userProfileMask-1x-png");
        borderImageView.backgroundColor = .clear
        
        pictureImageView.backgroundColor = .clear
        pictureImageView.image = placeholderImage
        
        self.addSubview(pictureImageView)
        self.addSubview(borderImageView)
    }
    
    override func layoutSubviews() {
        
        borderImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)

        let borderSize : CGFloat = 5.0
        var pictureFrame = borderImageView.frame
        pictureFrame.size.height =  pictureFrame.size.height - (2.0*borderSize)
        pictureFrame.size.width = pictureFrame.size.height
        pictureImageView.frame = pictureFrame
        pictureImageView.center = borderImageView.center
        pictureImageView.circle()
    }
}
