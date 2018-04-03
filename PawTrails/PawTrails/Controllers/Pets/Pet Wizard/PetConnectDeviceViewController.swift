//
//  PetConnectDeviceViewController.swift
//  PawTrails
//
//  Created by Bruno on 28/03/18.
//  Copyright © 2018 AttitudeTech. All rights reserved.
//

import UIKit
import swiftScan
import SCLAlertView
import GradientView

class PetConnectDeviceViewController: PetWizardStepViewController {

    var deviceCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureLayout()
    }

    fileprivate func configureLayout() {

        if let button = self.view.viewWithTag(69) {
            button.layer.cornerRadius = button.frame.size.height/2.0
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.verifyDeviceCode(deviceCode)
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
                
//                // Hide the status bar
//                strongSelf.statusBarShouldBeHidden = true
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
    
    @objc fileprivate func closeScannerViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scanDeviceCodeButtonTapped(_ sender: Any) {
        if UIDevice().isSimulator {
            showDeviceCodeAlert()
        } else {
            showQrCodeScanner()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.delegate?.stepCanceled(pet: self.pet!)
    }
    
    fileprivate func verifyDeviceCode(_ deviceCode: String) {
        if isBetaDemo {
            self.pet!.deviceCode = Constants.deviceIdforDemo
            self.delegate?.stepCompleted(completed: true, pet: self.pet!)
            self.delegate?.goToNextStep()
        } else {
            self.showLoadingView()
            APIRepository.instance.check(deviceCode, callback: {error, success in
                self.hideLoadingView()
                
                if let error = error {
                    var errorMessage = "Sorry, an error occoured"
                    
                    if let errorCodeDescription = error.errorCode?.description {
                        errorMessage = errorCodeDescription
                    }
                    self.showMessage(errorMessage, type: .error)
                } else {
                    if success {
                        self.deviceCode = deviceCode
                        self.pet!.deviceCode = deviceCode
                        self.delegate?.stepCompleted(completed: true, pet: self.pet!)
                        self.delegate?.goToNextStep()
                    } else {
                        self.showMessage("Code not available", type: .warning)
                    }
                }
            })
        }
    }
}

extension PetConnectDeviceViewController: QRCodeScannerViewControllerDelegate {
    
    func scanFinished(qrCodeScannerViewController: UIViewController, scanResult: String?, error: String?){
        
        if let error = error {
            self.alert(title: "=(", msg: error)
        } else if let scanResult = scanResult, qrCodeScannerViewController.presentingViewController != nil {
            qrCodeScannerViewController.dismiss(animated: true, completion: {
              self.verifyDeviceCode(scanResult)
            })
        }
    }
    
}

class HeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    fileprivate func setupView() {
        let gradientView = GradientView(frame: self.bounds)
        let gradientColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        // Set the gradient colors
        gradientView.colors = [gradientColor, .white]
        
        // Optionally set some locations
        gradientView.locations = [0.1, 0.7]
        
        // Optionally change the direction. The default is vertical.
        gradientView.direction = .vertical
        
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(gradientView)
        self.sendSubview(toBack: gradientView)
    }
}
