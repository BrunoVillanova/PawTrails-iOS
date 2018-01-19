//
//  StepOneViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import swiftScan

class StepOneViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    fileprivate func initialize() {
        self.navigationController?.navigationBar.backItem?.title = " "

//        BarcodeScanner.Title.text = NSLocalizedString("Scan QR Code", comment: "")
//        BarcodeScanner.CloseButton.text = NSLocalizedString("Close", comment: "")
//        BarcodeScanner.SettingsButton.text = NSLocalizedString("Settings", comment: "")
//        BarcodeScanner.Info.text = NSLocalizedString(
//            "Place the QR code within the window to scan. The search will start automatically.", comment: "")
//        BarcodeScanner.Info.loadingText = NSLocalizedString("Loading...", comment: "")
//        BarcodeScanner.Info.notFoundText = NSLocalizedString("No product found.", comment: "")
//        BarcodeScanner.Info.settingsText = NSLocalizedString(
//            "To scan the QR Code you have to allow camera access under iOS settings.", comment: "")
        
        if let nc = self.navigationController, nc.viewControllers.first == self {
            let closeBarButtonItem = UIBarButtonItem.init(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.closeViewController))
            self.navigationItem.setRightBarButton(closeBarButtonItem, animated: true)
        }
    }
    
    
    @objc fileprivate func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    @IBAction func scanNowBtnPressed(_ sender: Any) {
        QRCodeScannerViewController.authorizeCameraWith {[weak self](granted) in
            if granted, let strongSelf = self {
                let vc = QRCodeScannerViewController();
                vc.delegate = strongSelf;
                var style = LBXScanViewStyle()
                style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
                vc.scanStyle = style
                strongSelf.present(vc, animated: true, completion: {
                    UIApplication.shared.statusBarStyle = .default
                })
            }
        }
    }
    
    fileprivate func goToNextStep(deviceCode: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "StepTwoViewController") as? StepTwoViewController {
            vc.deviceCode = deviceCode
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
}


extension StepOneViewController: QRCodeScannerViewControllerDelegate {
    func scanFinished(qrCodeScannerViewController: UIViewController, scanResult: String, error: String?){
        if (qrCodeScannerViewController.presentingViewController != nil) {
            qrCodeScannerViewController.dismiss(animated: true, completion: {
                self.goToNextStep(deviceCode: scanResult)
            })
        }
    }
}
