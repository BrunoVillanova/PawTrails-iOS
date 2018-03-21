//
//  PTDonutAnnotationView.swift
//  PawTrails
//
//  Created by Bruno on 16/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit

class PTDonutAnnotationView: MKAnnotationView {
    
    static let identifier = "PTDonutAnnotationView"
    
    var petFocused: Bool = true {
        didSet {
            if petFocused {
                annotationImage = UIImage(named: "DonutIcon")
            } else {
                annotationImage = UIImage(named: "DonutIconGray")
            }
        }
    }
    
    let pictureImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
    var annotationImage = UIImage(named: "DonutIcon")
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func layoutSubviews() {
        let frame = pictureImageView.frame
        self.frame.size.height = frame.height
        self.frame.size.width = frame.width
    }
    
    fileprivate func initialize() {
        
        self.backgroundColor = UIColor.clear
//        self.centerOffset = CGPoint(x: 3, y: 4)
        self.image = nil
        
        pictureImageView.image = annotationImage
        self.addSubview(pictureImageView)
    }

}
