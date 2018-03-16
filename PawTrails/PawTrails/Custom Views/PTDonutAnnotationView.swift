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
    
    let pictureImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
    
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
        self.centerOffset = CGPoint(x: 3, y: 4)
        self.image = nil
        
        pictureImageView.image = UIImage(named: "DonutIcon")
        self.addSubview(pictureImageView)
    }

}
