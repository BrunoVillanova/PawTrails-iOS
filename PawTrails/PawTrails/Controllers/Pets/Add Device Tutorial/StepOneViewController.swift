//
//  StepOneViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import swiftScan
import SCLAlertView

class StepOneViewController: UIViewController {

    var statusBarShouldBeHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        // Show the status bar
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    fileprivate func initialize() {
        self.navigationController?.navigationBar.backItem?.title = " "
        if let nc = self.navigationController, nc.viewControllers.first == self {
            let closeBarButtonItem = UIBarButtonItem.init(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.closeViewController))
            self.navigationItem.setRightBarButton(closeBarButtonItem, animated: true)
        }
    }
    
    @objc fileprivate func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func showDeviceCodeAlert() {
        
        let title: String = "Device Code"
        let subTitle: String = "You are in simulator, please type in the device code"
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        let txt = alertView.addTextField("Device Code")
        
        alertView.addButton("Add Device") {
            if let deviceCode = txt.text {
                self.goToNextStep(deviceCode: deviceCode)
            }
        }
        
        alertView.showTitle(
            title,
            subTitle: subTitle,
            duration: 0.0,
            completeText: "ok",
            style: .wait,
            colorStyle: 0xD4143D,
            colorTextButton: 0xFFFFFF
        )
    }
    
    fileprivate func showQrCodeScanner() {
        QRCodeScannerViewController.authorizeCameraWith {[weak self](granted) in
            if granted, let strongSelf = self {
                let vc = QRCodeScannerViewController();
                vc.delegate = strongSelf;
                
                // Hide the status bar
                strongSelf.statusBarShouldBeHidden = true
                UIView.animate(withDuration: 0.25) {
                    strongSelf.setNeedsStatusBarAppearanceUpdate()
                }
                
                let navigationController = UINavigationController.init(rootViewController: vc)
                navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navigationController.navigationBar.shadowImage = UIImage()
                navigationController.navigationBar.isTranslucent = true
                navigationController.navigationBar.backgroundColor = UIColor.clear
                navigationController.navigationBar.tintColor = UIColor.white
                
                let barButtonItem = UIBarButtonItem.init(title: "Close", style: UIBarButtonItemStyle.plain, target:strongSelf, action: #selector(strongSelf.closeScannerViewController))
                
                vc.navigationItem.setRightBarButton(barButtonItem, animated: true)
                
                strongSelf.present(navigationController, animated: true, completion: {
                    
                })
            }
        }
    }
    
    @IBAction func scanNowBtnPressed(_ sender: Any) {
        if UIDevice().isSimulator {
            showDeviceCodeAlert()
        } else {
            showQrCodeScanner()
        }
    }
    
    @objc fileprivate func closeScannerViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func goToNextStep(deviceCode: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "StepTwoViewController") as? StepTwoViewController {
            vc.deviceCode = deviceCode
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
}


extension StepOneViewController: QRCodeScannerViewControllerDelegate {
    
    func scanFinished(qrCodeScannerViewController: UIViewController, scanResult: String?, error: String?){
        
        if let error = error {
            self.alert(title: "=(", msg: error)
        } else if let scanResult = scanResult, qrCodeScannerViewController.presentingViewController != nil {
            qrCodeScannerViewController.dismiss(animated: true, completion: {
                if isBetaDemo {
                    self.goToNextStep(deviceCode: Constants.deviceIdforDemo)
                }
                else {
                    self.goToNextStep(deviceCode: scanResult)
                }
            })
        }
    }
    
}
