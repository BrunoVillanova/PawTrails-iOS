//
//  PTBasicAnnotationView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 11/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class PTBasicAnnotationView: MKAnnotationView {

    static let identifier = "PTBasicAnnotationView"
    let pictureImageView = PTBalloonImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    var calloutView: PTPetCalloutView?
    let defaultAnimationDuration = 0.3
    var calloutDelegate: PTPetCalloutViewDelegate?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func prepareForReuse() {
        calloutView?.isHidden = true
        pictureImageView.image = nil
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil) {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        
        if (!isInside) {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break
                }
            }
        }
        
        return isInside
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = pictureImageView.frame
        self.frame.size.height = frame.height
        self.frame.size.width = frame.width

        if let calloutView = calloutView {
            calloutView.center = CGPoint(x: -4, y: -90)
        }
    }
    
    private func initialize() {
        self.backgroundColor = UIColor.clear
        self.centerOffset = CGPoint(x: 0, y: -30)
        self.addSubview(pictureImageView)
        self.image = nil
    }
    
    func configureWithAnnotation(_ annotation: PTAnnotation) {
        if let petDeviceData = annotation.petDeviceData, let imageUrl = petDeviceData.pet.imageURL {
            pictureImageView.imageUrl = imageUrl
        }
    }
    
    func showCallout() {
        
        if calloutView == nil {
            
            calloutView = PTPetCalloutView(frame: .zero)
            if let calloutDelegate = calloutDelegate {
                calloutView?.delegate = calloutDelegate
            }
            calloutView?.alpha = 0
            self.addSubview(calloutView!)
        }

        let petAnnotation = self.annotation as! PTAnnotation
        calloutView?.configureWithAnnotation(petAnnotation)
        calloutView?.isHidden = false
        calloutView?.setNeedsLayout()

        UIView.animate(withDuration: defaultAnimationDuration) {
            self.calloutView?.alpha = 1
        }
    }
    
    func hideCallout() {
        UIView.animate(withDuration: defaultAnimationDuration, animations: {
            self.calloutView?.alpha = 0
        }) { (finished) in
            if finished {
                self.calloutView?.isHidden = true
            }
        }
    }
}
