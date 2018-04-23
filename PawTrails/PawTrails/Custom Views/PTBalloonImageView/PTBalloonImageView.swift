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
    let onlineImage = UIImage(named: "PetImageBalloonOnline")!
    let offlineImage = UIImage(named: "PetImageBalloonOffline")!
    
    var borderImageView = UIImageView(frame: CGRect.zero)
    var pictureImageView = UIImageView(frame: CGRect.zero)
    var petFocused : Bool = true {
        didSet {
            updateBackground()
        }
    }
    
    let backgroundLayer = CALayer()
    fileprivate var backgroundImage: UIImage?
    
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
                pictureImageView.image = placeholderImage
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
        self.backgroundImage = petFocused ? onlineImage : offlineImage

        borderImageView.backgroundColor = .clear
        
        pictureImageView.backgroundColor = .clear
        pictureImageView.image = placeholderImage
    
        self.addSubview(pictureImageView)
        
        var frame = self.frame
        frame.size.width = onlineImage.size.width
        frame.size.height = onlineImage.size.height
        self.frame = frame

        self.layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = self.bounds
        let borderSize: CGFloat = 3.5
        let theWidth = self.bounds.size.width - (2.0*borderSize)
        pictureImageView.frame = CGRect(x: borderSize, y: borderSize, width: theWidth, height: theWidth)
        pictureImageView.circle()
    }
    
    fileprivate func updateBackground() {
        self.backgroundImage = petFocused ? onlineImage : offlineImage
        backgroundLayer.contents = backgroundImage?.cgImage
        self.layer.contentsGravity = kCAGravityResizeAspect
    }
}
