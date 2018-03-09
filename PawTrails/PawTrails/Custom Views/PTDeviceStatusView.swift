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
    
    var signalView: PTSignalView?
    var batteryView: PTBatteryView?
    var connectionStatusView: PTConnectionStatusView?
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 48, height: 15)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        // Add all subview for status
        signalView = PTSignalView()
        signalView?.alpha = 0
        signalView?.isHidden = true
        self.addSubview(signalView!)

        batteryView = PTBatteryView()
        batteryView?.alpha = 0
        batteryView?.isHidden = true
        self.addSubview(batteryView!)
        
        connectionStatusView = PTConnectionStatusView()
        connectionStatusView?.alpha = 0
        connectionStatusView?.isHidden = true
        self.addSubview(connectionStatusView!)
        
        // Configure constraints
        signalView?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
            make.left.equalToSuperview()
        }

        batteryView?.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(10)
        }
        
        connectionStatusView?.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }
    }
    
    open func resetAllSubviews() {
        signalView?.alpha = 0
        signalView?.isHidden = true
        batteryView?.alpha = 0
        batteryView?.isHidden = true
        connectionStatusView?.alpha = 0
        connectionStatusView?.isHidden = true
    }
    
    func configure(_ petDeviceData: PetDeviceData, animated: Bool = true) {

        if (petDeviceData.deviceConnection.status == 0) {
            connectionStatusView?.alpha = 1
            connectionStatusView?.isHidden = false
            connectionStatusView?.setStatus(petDeviceData.deviceConnection.status)
            signalView?.isHidden = true
            batteryView?.isHidden = true
        } else {
            connectionStatusView?.isHidden = true
            signalView?.alpha = 1
            signalView?.isHidden = false
            signalView?.setSignal(petDeviceData.deviceData.networkLevel, animated: animated)
            
            batteryView?.alpha = 1
            batteryView?.isHidden = false
            batteryView?.setBatteryLevel(petDeviceData.deviceData.batteryLevel, animated: animated)
        }

//        UIView.animate(withDuration: 2.0) {
//
//        }
    }

}
