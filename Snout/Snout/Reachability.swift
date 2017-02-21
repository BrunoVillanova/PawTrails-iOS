//
//  Reachability.swift
//  Snout
//
//  Created by Marc Perello on 17/02/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import Foundation
import SystemConfiguration

class Reachbility {
    
    private var _isConnected = true
    private let view: ConnectionView!
    weak private var timer:Timer!
    
    init(_ view: ConnectionView) {
        self.view = view
        checkConnection()
    }
    
    func isConnected() -> Bool {
        checkConnection()
        return _isConnected
    }
    
    @objc private func checkConnection() {
        if _isConnected != isConnectedToNetwork() {
            _isConnected = isConnectedToNetwork()
            if _isConnected {
                DispatchQueue.main.async {
                    self.view.connectedToNetwork()
                }
            }else{
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: true)
                DispatchQueue.main.async {
                    self.view.notConnectedToNetwork()
                }
            }
        }
    }
    
    private func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }
}
