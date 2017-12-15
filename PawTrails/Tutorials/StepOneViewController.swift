//
//  StepOneViewController.swift
//  PawTrails
//
//  Created by Mohamed Ibrahim on 14/12/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import BarcodeScanner


class StepOneViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        BarcodeScanner.Title.text = NSLocalizedString("Scan QR Code", comment: "")
        BarcodeScanner.CloseButton.text = NSLocalizedString("Close", comment: "")
        BarcodeScanner.SettingsButton.text = NSLocalizedString("Settings", comment: "")
        BarcodeScanner.Info.text = NSLocalizedString(
            "Place the QR code within the window to scan. The search will start automatically.", comment: "")
        BarcodeScanner.Info.loadingText = NSLocalizedString("Loading...", comment: "")
        BarcodeScanner.Info.notFoundText = NSLocalizedString("No product found.", comment: "")
        BarcodeScanner.Info.settingsText = NSLocalizedString(
            "To scan the QR Code you have to allow camera access under iOS settings.", comment: "")
    }
    
    @IBAction func scanNowBtnPressed(_ sender: Any) {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
}



extension StepOneViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "StepTwoViewController") as? StepTwoViewController {
            vc.deviceCode = code
            controller.present(vc, animated: true, completion: {
            })
        }
    }
}

extension StepOneViewController: BarcodeScannerErrorDelegate {
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
}

extension StepOneViewController: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

