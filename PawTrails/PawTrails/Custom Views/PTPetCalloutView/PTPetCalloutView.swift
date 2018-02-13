//
//  PTPetCalloutView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 17/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit

protocol PTPetCalloutViewDelegate {
    func didTapOnCallout(annotation: PTAnnotation)
}

class PTPetCalloutView: UIView {

    var petNameLabel : UILabel?
    var addressLabel : UILabel?
    var batteryView : PTBatteryView?
    var annotation : PTAnnotation?
    var delegate: PTPetCalloutViewDelegate?
    
    override func awakeFromNib() {
        petNameLabel = self.viewWithTag(100) as? UILabel
        addressLabel = self.viewWithTag(110) as? UILabel
        batteryView = self.viewWithTag(200) as? PTBatteryView
    }

    @objc fileprivate func tappedOnView(sender: UITapGestureRecognizer) {
        if let theAnnotation = self.annotation as PTAnnotation! {
            delegate?.didTapOnCallout(annotation: theAnnotation)
        }
    }
    
    public func configureWithAnnotation(_ annotation: PTAnnotation) {
        
        self.annotation = annotation
        
        petNameLabel?.text = nil
        addressLabel?.text = nil
        
        if let petName = annotation.petDeviceData?.pet.name {
            petNameLabel?.text = petName.uppercased()
        }
        
        if let deviceData = annotation.petDeviceData?.deviceData {
            batteryView?.setBatteryLevel(deviceData.battery)
            
            self.addressLabel?.text = "Getting address..."
            deviceData.point.getFullFormatedAddress(handler: {
                (address, error) in
                
                if error == nil, let address = address {
                    self.addressLabel?.text = address.uppercased()
                    self.addressLabel?.sizeToFit()
                }

            })
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.tappedOnView(sender:)))
        self.addGestureRecognizer(gesture)
    }
}
