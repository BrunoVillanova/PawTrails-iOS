//
//  PTBasicAnnotationView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 11/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit

class PTBasicAnnotationView: MKAnnotationView {

    static let identifier = "PTBasicAnnotationView"
    var borderImageView: UIImageView?
    var pictureImageView: UIImageView?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        pictureImageView?.image = nil
    }
    
    private func initialize() {
        
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        self.backgroundColor = UIColor.clear
        
        borderImageView = UIImageView(frame: self.frame)
        borderImageView!.image = #imageLiteral(resourceName: "userProfileMask-1x-png");
        self.addSubview(borderImageView!)
        
        let pictureBaseSize : CGFloat = 13.0
        var pictureFrame = CGRect()
        pictureFrame.size.height = self.frame.size.height - pictureBaseSize
        pictureFrame.size.width = pictureFrame.size.height
        pictureImageView = UIImageView()
        pictureImageView?.frame = pictureFrame
        pictureImageView?.center = self.center
        pictureFrame = pictureImageView!.frame
        pictureFrame.origin.y = pictureFrame.origin.y - 2
        pictureImageView?.frame = pictureFrame
        pictureImageView?.circle()
        pictureImageView?.backgroundColor = UIColor.clear
        self.addSubview(pictureImageView!)
        self.bringSubview(toFront: pictureImageView!)
    }
    
    func configureWithPetDeviceData(_ petDeviceData: PetDeviceData) {
        if let image = petDeviceData.pet.image {
            pictureImageView?.image = UIImage(data: image)
        }
    }
}
