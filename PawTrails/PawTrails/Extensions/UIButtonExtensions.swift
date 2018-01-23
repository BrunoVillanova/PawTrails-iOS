//
//  UIButtonExtensions.swift
//  PawTrails
//
//  Created by Bruno Villanova on 22/11/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func changeImageAnimated(image: UIImage?) {
        guard let imageView = self.imageView, let currentImage = imageView.image, let newImage = image else {
            return
        }
        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFade.duration = 0.3
        crossFade.fromValue = currentImage.cgImage
        crossFade.toValue = newImage.cgImage
        crossFade.isRemovedOnCompletion = false
        crossFade.fillMode = kCAFillModeForwards
        imageView.layer.add(crossFade, forKey: "animateContents")
    }
}
