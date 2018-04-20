//
//  PTDeviceStatusView.swift
//  PawTrails
//
//  Created by Bruno Villanova on 01/02/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import SnapKit

class PTDeviceStatusView: UIView {
    
    let signalView = PTSignalView()
    let batteryView = PTBatteryView()
    let connectionStatusView = PTConnectionStatusView()
    var currentData: PetDeviceData?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override public var intrinsicContentSize: CGSize {

        if connectionStatusView.superview != nil {
            return CGSize(width: connectionStatusView.frame.size.width, height: connectionStatusView.frame.size.height)
        } else if signalView.superview != nil && batteryView.superview != nil {
            let width = signalView.frame.size.width + (batteryView.frame.origin.y - signalView.frame.size.width) + batteryView.frame.size.width
            let height = signalView.frame.size.height
            return CGSize(width: width, height: height)
        }

        return CGSize.zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if signalView.superview != nil {
            signalView.snp.remakeConstraints { (make) -> Void in
                make.top.greaterThanOrEqualToSuperview().offset(0)
                make.bottom.greaterThanOrEqualToSuperview().offset(0)
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
        }
        
        if batteryView.superview != nil {
            batteryView.snp.remakeConstraints { (make) -> Void in
                make.top.greaterThanOrEqualToSuperview().offset(0)
                make.bottom.lessThanOrEqualToSuperview().offset(0)
                
                if signalView.superview != nil {
                    make.left.equalTo(signalView.snp.right).offset(12)
                }
                
                make.right.equalToSuperview()
                make.centerY.equalTo(signalView)
                make.width.equalTo(20)
                make.height.equalTo(10)
            }
        }
        
        if connectionStatusView.superview != nil {
            connectionStatusView.snp.remakeConstraints { (make) -> Void in
                make.edges.equalToSuperview()
            }
        }
        
        self.invalidateIntrinsicContentSize()
    }
    
    fileprivate func setupView() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(_ petDeviceData: PetDeviceData, animated: Bool = true) {
        
        if (petDeviceData.deviceConnection.status == 0) {
            signalView.removeFromSuperview()
            batteryView.removeFromSuperview()
            
            connectionStatusView.setStatus(petDeviceData.deviceConnection.status)
            self.addSubview(connectionStatusView)
            
        } else {
            
            connectionStatusView.removeFromSuperview()
            
            self.addSubview(signalView)
            signalView.setSignal(petDeviceData.deviceData.networkLevel, animated: animated)
            
            self.addSubview(batteryView)
            batteryView.setBatteryLevel(petDeviceData.deviceData.batteryLevel, animated: animated)
        }

        UIView.animate(withDuration: 0.3) {
            if self.signalView.superview != nil {
                self.signalView.alpha = 1
            }

            if self.batteryView.superview != nil {
                self.batteryView.alpha = 1
            }

            if self.connectionStatusView.superview != nil {
                self.connectionStatusView.alpha = 1
            }
        }
    }

}
