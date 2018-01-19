//
//  QRCodeScannerViewController.swift
//  PawTrails
//
//  Created by Bruno on 19/01/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import swiftScan
import AVFoundation

public protocol QRCodeScannerViewControllerDelegate {
    func scanFinished(qrCodeScannerViewController: UIViewController, scanResult: String, error: String?)
}

class QRCodeScannerViewController: LBXScanViewController {

    var delegate: QRCodeScannerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        if let scanResult = arrayResult[0].strScanned {
            delegate?.scanFinished(qrCodeScannerViewController: self, scanResult: scanResult, error: nil)
        }
    }
    
    fileprivate func initialize() {
        
    }

    static func authorizeCameraWith(completion:@escaping (Bool) -> Void ) {
        
        let granted = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo);
        
        switch granted {
            case AVAuthorizationStatus.authorized:
                completion(true)
                break;
            case AVAuthorizationStatus.denied:
                goToSystemPrivacySettings()
                completion(false)
                break;
            case AVAuthorizationStatus.restricted:
                goToSystemPrivacySettings()
                completion(false)
                break;
            case AVAuthorizationStatus.notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted:Bool) in
                    if (!granted) {
                        goToSystemPrivacySettings()
                    }
                    completion(granted)
                })
        }
    }
    
    fileprivate static func goToSystemPrivacySettings() {
        if let appSetting = URL(string:UIApplicationOpenSettingsURLString) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
            } else{
                UIApplication.shared.openURL(appSetting)
            }
        }
    }
    

}
