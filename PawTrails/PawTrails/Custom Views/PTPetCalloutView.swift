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
    var batteryView : PTBatteryView?
    
    override func awakeFromNib() {
        petNameLabel = self.viewWithTag(100) as? UILabel
        addressLabel = self.viewWithTag(110) as? UILabel
        batteryView = self.viewWithTag(200) as? PTBatteryView
    }

    public func configureWithAnnotation(_ annotation: PTAnnotation) {
        
        if let petName = annotation.petDeviceData?.pet.name {
            petNameLabel?.text = petName
        }
        
        self.addressLabel?.text = ""
        
        if let deviceData = annotation.petDeviceData?.deviceData {
            
            batteryView?.setBatteryLevel(deviceData.battery)
            
            self.addressLabel?.text = "Getting address..."
            deviceData.coordinates.getFullFormatedAddress(handler: {
                (address) in
                self.addressLabel?.text = address
                self.addressLabel?.sizeToFit()
            })
        }
    }
}
