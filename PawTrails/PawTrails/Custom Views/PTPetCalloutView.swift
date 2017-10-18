//
//  PTPetCalloutView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 17/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

class PTPetCalloutView: UIView {

    var petNameLabel : UILabel?
    var addressLabel : UILabel?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        petNameLabel = self.viewWithTag(100) as? UILabel
        addressLabel = self.viewWithTag(110) as? UILabel
    }

    public func configureWithAnnotation(_ annotation: PTAnnotation) {
        if let petName = annotation.petDeviceData?.pet.name {
            petNameLabel?.text = petName
        }
        
        self.addressLabel?.text = ""
        
        if let petCoordinates = annotation.petDeviceData?.deviceData.coordinates {
            self.addressLabel?.text = "Getting address..."
            petCoordinates.getFullFormatedAddress(handler: {
                (address) in
                self.addressLabel?.text = address
            })
        }
    }
}
