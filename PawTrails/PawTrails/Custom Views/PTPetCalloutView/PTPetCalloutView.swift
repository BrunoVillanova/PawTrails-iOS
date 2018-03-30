//
//  PTPetCalloutView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 17/10/17.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

protocol PTPetCalloutViewDelegate {
    func didTapOnCallout(annotation: PTAnnotation)
}

class PTPetCalloutView: UIView {
    
    @IBOutlet weak var bubbleView: PTBubbleView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var deviceStatusView: PTDeviceStatusView!
    var annotation : PTAnnotation?
    var delegate: PTPetCalloutViewDelegate?
    var contentView: UIView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let contentView = contentView {
            var frame = self.frame
            frame.size.height = contentView.frame.size.height
            frame.size.width = contentView.frame.size.width
            self.frame = frame
            
            frame = contentView.frame
            frame.origin.x = 0
            frame.origin.y = 0
            contentView.frame = frame

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
    
        
        let nib = Bundle.main.loadNibNamed("PTPetCalloutView", owner: self, options: nil)
        
        if let contentView = nib?.first as? UIView {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            self.contentView = contentView
        }
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.tappedOnView(sender:)))
        bubbleView.addGestureRecognizer(gesture)
    }

    @objc fileprivate func tappedOnView(sender: UITapGestureRecognizer) {
        if let theAnnotation = self.annotation as PTAnnotation? {
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
        
        if let petDeviceData = annotation.petDeviceData, let addressLabel = addressLabel {
            deviceStatusView?.configure(petDeviceData)
            
            if let point = petDeviceData.deviceData.point {
                addressLabel.text = "Getting address..."
                point.getFullFormatedAddress(handler: {
                    (address, error) in
                    
                    if error == nil, let address = address {
                        addressLabel.text = address.uppercased()
                    }
                    
                })
            }
        }
    }
}
